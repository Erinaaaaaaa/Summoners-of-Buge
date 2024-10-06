extends Area2D
class_name Boid

enum Behavior {
	NEUTRAL,
	FOLLOW
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

@export_category("Rules")
@export var max_speed = 500
@export var cohesion_strength = 5
@export var separation_strength = 1000
@export var alignment_strength = 10

# --------------------------------
var visible_boids : Array[Area2D]

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
	print(position)

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

# Returns angle/speed delta.
func get_steering() -> Vector2:
	if !visible_boids:
		return Vector2.ZERO	
	
	var total_steering = Vector2.ZERO
	var processed_count = 0
	
	for b in visible_boids:
		var boid:Boid = b
		var steering = Vector2.ZERO
		
		steering += rule_cohesion(boid) * cohesion_strength
		steering += rule_separation(boid) * separation_strength
		steering += rule_alignment(boid) * alignment_strength
		
		total_steering += steering
		processed_count += 1
	
	return total_steering / processed_count

# Aim to get close to the other boid.
func rule_cohesion(other: Boid) -> Vector2:
	return other.position - self.position

# Increase the separation strength the closer you are to the other boid.
func rule_separation(other: Boid) -> Vector2:
	return (self.position - other.position) / max(1e-10, (self.position - other.position).length())

# Aim to match the velocity of the other boid.
func rule_alignment(other: Boid) -> Vector2:
	return other.velocity

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
