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
@export var health = 1
@export var damage = 1
@export var damage_capacity = 3

@export_category("Rules")
@export var max_speed = 300
@export var aggression_check_distance = 50

@export var cohesion_strength = 20
@export var separation_strength = 1000
@export var alignment_strength = 10
@export var wizard_kill_strength = 1000

@export var predator_cohesion_strength = 50

@export var prey_separation_strength = 1800

@export var wizard_node: Node2D
@export var goal_strength = 0

@export_category("Sounds")
@export var boid_death : AudioStream

# --------------------------------
var battlefield : Battlefield

var visible_boids : Array[Area2D]
var type = ""

var current_behavior = Behavior.NEUTRAL
var steer_towards = Vector2()

var enabled = true

var velocity = Vector2.ZERO


# ---------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	battlefield = get_tree().current_scene
	var angle = global_rotation
	velocity = Vector2.RIGHT.rotated(angle) * 50 #base speed
	current_behavior = Behavior.NEUTRAL
	
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.start()
	$Sprite.play()

func _process(delta: float):
	if !enabled: return
	if !GameManager.is_game_running: delete(false)
	
	var steering = get_steering()
	
	# Update motion settings
	velocity = lerp(velocity, velocity + steering, 0.5 * delta)
	# Keep speed in check
	if velocity.length_squared() > max_speed**2:
		velocity = velocity.normalized() * max_speed
	
	# Perform steering step
	global_position += velocity * delta
	
	# Keep inbounds.
	check_bounds()
	
	rotation = velocity.angle()

var bottom_right = Vector2(1280, 720)

func check_bounds():
	if global_position.x < 0:
		velocity.x *= -1
	if global_position.y < 0:
		velocity.y *= -1
	
	if global_position.x >  bottom_right.x:
		velocity.x *= -1
	if global_position.y > bottom_right.y:
		velocity.y *= -1
	
	global_position = global_position.clamp(Vector2(0, 0), bottom_right)

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
		if !b.enabled:
			continue
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
		if !b.enabled:
			continue
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
		+ rule_alignment(boid) * alignment_strength
		+ rule_wizard() * wizard_kill_strength)

## Check if other is a prey.
func is_prey(other: Boid) -> bool:
	return other.team != self.team and other.damage_priority <= self.damage_priority

## Check if other is a predator.
func is_predator(other: Boid) -> bool:
	return other.team != self.team and other.damage_priority > self.damage_priority

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

## Look for the goal.
func rule_goal() -> Vector2:
	return Vector2.ZERO

func rule_wizard() -> Vector2:
	return -(self.position - wizard_node.position) / max(1e-10, (self.position - wizard_node.position).length())

func set_sprite(sprite_res):
	$Sprite.set_sprite_frames(load(ResourcesManager.sprites[sprite_res]))

func set_team(team):
	self.team = team
	match team:
		Enums.Team.RED:
			modulate = Color(1, 0.3, 0.3)
		Enums.Team.BLUE:
			modulate = Color(0.3, 0.3, 1)

## Properly remove this boid from the universe.
func delete(use_fx : bool = true):
	enabled = false
	if use_fx:
		var p = ParticlesManager.create_particle("die", battlefield)
		p.rotation_degrees = global_rotation
		p.global_position = global_position
		SoundManager.play_sound(boid_death,2,-3)
	emit_signal("deleted", self)
	queue_free()

func _on_vision_area_entered(area : Area2D):
	if area != self and area.is_in_group("boid"):
		visible_boids.append(area)


func _on_vision_area_exited(area):
	if area != self and area.is_in_group("boid"):
		visible_boids.erase(area)


func _on_area_entered(area):
	if area == self:
		return
	if area is Wizard and area.team != self.team:
		area.hit()
		delete()
	if area.is_in_group("boid"):
		# Check wether we're the one attacked or not.
		# (The other boid comes at us at a 90 degree angle or from front)
		var b : Boid = area
		if team != b.team:
			if damage_priority >= b.damage_priority:
				damage_capacity -= 1
				if damage_capacity == 0: delete()
			# If taking damage, or after having dealt too much damage
			if damage_priority <= b.damage_priority:
				health -= 1
				if health <= 0: delete()
