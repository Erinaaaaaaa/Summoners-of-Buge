extends Area2D
class_name Boid

@export_category("Visual")
@export var sprite : AnimatedSprite2D

@export_category("Raycasts")
@export var raycastFrontL : RayCast2D
@export var raycastFrontR : RayCast2D
@export var raycastSideL : RayCast2D
@export var raycastSideR : RayCast2D

@export_category("Zones")
@export var vision_area : Area2D

@export_category("General")
@export var velocity = Vector2()
@export var speed = 100

# --------------------------------
var visible_boids : Array[Area2D]
# ---------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	#Initial velocity
	velocity = Vector2(randf_range(-1,1), randf_range(-1,1)) * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_neighbors(delta * 10)
	check_sides()
	
	velocity = velocity.normalized() * speed
	
	move(delta)
	
	rotation = velocity.normalized().angle()
	


func check_sides():
	pass

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
		
		velocity += steer_away * delta
		velocity = lerp(velocity, avg_velocity, 0.5 * delta)
		velocity += (avg_position - position) * delta
	
func move(delta):
	global_position += velocity * delta
	
	if global_position.x < 0:
		global_position.x  = get_viewport_rect().size.x
	if global_position.y < 0:
		global_position.y = get_viewport_rect().size.y
		
	if global_position.x >  get_viewport_rect().size.x:
		global_position.x = 0
	if global_position.y > get_viewport_rect().size.y:
		global_position.y = 0
		
	


func _on_vision_area_entered(area : Area2D):
	if area != self and area.is_in_group("boid"):
		visible_boids.append(area)


func _on_vision_area_exited(area):
	if area != self and area.is_in_group("boid"):
		visible_boids.erase(area)
