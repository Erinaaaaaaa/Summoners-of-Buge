extends Area2D
class_name Boid

enum Behavior {
	NEUTRAL,
	FOLLOW
}

@export_category("Visual")
@export var sprite : AnimatedSprite2D

@export_category("Raycasts")
@export var raycasts_node : Node2D

@export_category("Zones")
@export var vision_area : Area2D

@export_category("General")
@export var velocity = Vector2()
@export var speed = 50
@export var team = Enums.Team.RED
@export var max_boids_vision = 5

# --------------------------------
var visible_boids : Array[Area2D]

var current_behavior = Behavior.NEUTRAL
var steer_towards = Vector2()

var max_delta = 1.0/60
var enabled = true

# ---------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	#Initial velocity
	velocity = Vector2(randf_range(-1,1), randf_range(-1,1)) * speed
	
	current_behavior = Behavior.NEUTRAL

func _process(delta: float):
	if !enabled: return
	var eff_delta = min(max_delta, delta)
	
	check_neighbors(eff_delta * 10)
	check_sides(eff_delta)
	
	velocity = velocity.normalized() * speed
	
	move(eff_delta)
	
	rotation = velocity.normalized().angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func check_sides(delta):
	for r in raycasts_node.get_children():
		var ray : RayCast2D = r
		if ray.get_collider() and ray.is_colliding():
			if ray.get_collider().is_in_group("solid") or ray.get_collider().is_in_group(get_pool_area_name()):
				var magi = 100 / (r.get_collision_point() - global_position).length_squared() # magi = magnitude
				velocity -= (r.target_position.rotated(rotation) * magi)

func check_neighbors(delta):
	if visible_boids:
		var n_boids = visible_boids.size()
		var avg_velocity = Vector2.ZERO
		var avg_position = Vector2.ZERO
		var steer_away = Vector2.ZERO
		
		for b in visible_boids:
			avg_position += b.global_position
			avg_velocity += b.velocity
			
			steer_away -= (b.global_position - global_position) * (48 / (global_position - b.global_position).length())
		
		avg_position /= n_boids
		avg_velocity /= n_boids
		
		# Steer away from neighbors
		velocity += steer_away * delta
		# Match neighbors velocity
		velocity = lerp(velocity, avg_velocity, 0.5 * delta)
		# Steer towards neighbors position
		velocity += (avg_position - position) * delta
		
	
	# Steer towards goal
	if current_behavior == Behavior.FOLLOW: 
		velocity += (steer_towards - position) * delta
	
func move(delta):
	global_position += velocity * delta

func torus_warp():
	if global_position.x < 0:
		global_position.x  = get_viewport_rect().size.x
	if global_position.y < 0:
		global_position.y = get_viewport_rect().size.y
		
	if global_position.x >  get_viewport_rect().size.x:
		global_position.x = 0
	if global_position.y > get_viewport_rect().size.y:
		global_position.y = 0

func get_pool_area_name():
	if team == Enums.Team.RED:
		return "red_pool_area"
	if team == Enums.Team.BLUE:
		return "blue_pool_area"
		
	return "unknown"

func delete():
	enabled = false
	queue_free()

func _on_vision_area_entered(area : Area2D):
	if area != self and area.is_in_group("boid") and visible_boids.size() < max_boids_vision:
		visible_boids.append(area)


func _on_vision_area_exited(area):
	if area != self and area.is_in_group("boid"):
		visible_boids.erase(area)
