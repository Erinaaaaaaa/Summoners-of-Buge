extends Area2D
class_name Boid

enum Behavior {
	NEUTRAL,
	PREDATOR,
	PREY
}

signal deleted(Boid)

@export_category("Visual")
@export var sprite : AnimatedSprite2D

@export_category("Raycasts")
@export var raycasts_node : Node2D

@export_category("Zones")
@export var vision_area : Area2D

@export_category("General")
@export var team = Enums.Team.RED
@export var max_boids_vision = 5
@export var damage_priority = 0
@export var lifetime = 20

@export_category("Rules")
@export var max_speed = 300
@export var aggression_check_distance = 50

@export var cohesion_strength = 20
@export var separation_strength = 1000
@export var alignment_strength = 10

@export var predator_cohesion_strength = 50

@export var prey_separation_strength = 1800

# --------------------------------
var visible_boids : Array[Area2D]
var type = ""

var current_behavior = Behavior.NEUTRAL
var steer_towards = Vector2()

var enabled = true

var velocity = Vector2.ZERO

var health = 1
# ---------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	var angle = randf_range(0, 2*PI)
	velocity = Vector2.RIGHT.rotated(angle) * 50 #base speed
	current_behavior = Behavior.NEUTRAL
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.start()

func _process(delta: float):
	if !enabled: return
	
	var steering = get_steering()
	
	# Update motion settings
	velocity = lerp(velocity, velocity + steering, 0.5 * delta)
	# Keep speed in check
	if velocity.length_squared() > max_speed**2:
		velocity = velocity.normalized() * max_speed
	
	# Perform steering step
	global_position += velocity * delta
	
	# Keep inbounds.
	torus_warp()
	
	rotation = velocity.angle()

func torus_warp():
	if global_position.x < 0:
		velocity.x *= -1
	if global_position.y < 0:
		velocity.y *= -1
	
	if global_position.x >  get_viewport_rect().size.x:
		velocity.x *= -1
	if global_position.y > get_viewport_rect().size.y:
		velocity.y *= -1
	
	global_position = global_position.clamp(Vector2(0, 0), get_viewport_rect().size)

# Returns angle/speed delta.
func get_steering() -> Vector2:
	if !visible_boids:
		return Vector2.ZERO
	
	var total_steering = Vector2.ZERO
	var processed_count = 0
	
	# Check for behavior mode.
	current_behavior = Behavior.NEUTRAL
	for b in visible_boids:
		var boid:Boid = b
		var target_behavior = check_aggression(boid)
		# Break out if you're a prey - you're running no matter what.
		if target_behavior == Behavior.PREY:
			current_behavior = target_behavior
			break
		
		# Only become a predator if there's reason to.
		if target_behavior == Behavior.PREDATOR:
			current_behavior = target_behavior
	
	# Process motion
	for b in visible_boids:
		var boid:Boid = b
		var steering = Vector2.ZERO
		
		match current_behavior:
			Behavior.NEUTRAL:
				steering = steering_as_neutral(boid) # live the best life
			Behavior.PREY:
				if !is_predator(boid): # Only consider enemy predators
					continue
				steering = steering_as_prey(boid)
			Behavior.PREDATOR:
				if !is_prey(boid): # Only consider enemy preys
					continue
				steering = steering_as_predator(boid)
		
		total_steering += steering
		processed_count += 1
	
	# Avoid a silly division by zero.
	if processed_count > 0:
		return total_steering / processed_count
	else:
		return Vector2.ZERO

# Home in for the kill
func steering_as_predator(boid:Boid) -> Vector2:
	return rule_cohesion(boid) * predator_cohesion_strength

# Run for your life
func steering_as_prey(boid:Boid) -> Vector2:
	return rule_separation(boid) * prey_separation_strength

# Enjoy life with your flock
func steering_as_neutral(boid:Boid) -> Vector2:
	return (rule_cohesion(boid) * cohesion_strength
		+ rule_separation(boid) * separation_strength
		+ rule_alignment(boid) * alignment_strength)

## Check if other is a prey.
func is_prey(other: Boid) -> bool:
	return other.damage_priority < self.damage_priority

## Check if other is a predator.
func is_predator(other: Boid) -> bool:
	return other.damage_priority > self.damage_priority

## Check aggression mode.
func check_aggression(other: Boid) -> Behavior:
	# Out of range for aggression check - opt for neutral behavior
	if (aggression_check_distance**2 > (other.position - self.position).length_squared()):
		return Behavior.NEUTRAL
	
	# Predator in range.
	if is_predator(other):
		return Behavior.PREY
	
	# Prey in range.
	if is_prey(other):
		return Behavior.PREDATOR
	
	return Behavior.NEUTRAL

## Aim to get close to the other boid.
func rule_cohesion(other: Boid) -> Vector2:
	return other.position - self.position

## Increase the separation strength the closer you are to the other boid.
func rule_separation(other: Boid) -> Vector2:
	return (self.position - other.position) / max(1e-10, (self.position - other.position).length())

## Aim to match the velocity of the other boid.
func rule_alignment(other: Boid) -> Vector2:
	return other.velocity

## Properly remove this boid from the universe.
func delete():
	enabled = false
	emit_signal("deleted", self)
	queue_free()

func _on_vision_area_entered(area : Area2D):
	if area != self and area.is_in_group("boid"):
		visible_boids.append(area)


func _on_vision_area_exited(area):
	if area != self and area.is_in_group("boid"):
		visible_boids.erase(area)


func _on_area_entered(area):
	if area != self and area.is_in_group("boid"):
		# Check wether we're the one attacked or not.
		# (The other boid comes at us at a 90 degree angle or from front)
		var b : Boid = area
		if team != b.team:
			if damage_priority <= b.damage_priority:
				delete()
