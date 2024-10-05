extends Area2D
class_name Wizard

#--- Exported vars ---
@export_category("Properties")
@export var team = Enums.Team.RED
@export var pool_area : Area2D
@export var boid_node : Node2D

@export_category("Prefabs")
@export var boid_scene : PackedScene

#--- private vars ---
var my_boids = []



# Called when the node enters the scene tree for the first time.
func _ready():
	if team == Enums.Team.RED:
		pool_area.add_to_group("red_pool_area")
	if team == Enums.Team.BLUE:
		pool_area.add_to_group("blue_pool_area")
	
	$SpawnTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_boid():
	if my_boids.size() >= 50:
		print("Too many boids. skipping creation")
		return
	
	print("Creating new boid")
	var angle = randf_range(0, 2*PI)
	var distance = randf_range(30, 180)
	
	var instance: Boid = boid_scene.instantiate()
	var local_pos = Vector2.RIGHT.rotated(angle) * distance
	instance.position = local_pos
	
	#temp
	if team == Enums.Team.BLUE:
		instance.team = Enums.Team.RED
	elif team == Enums.Team.RED:
		instance.team = Enums.Team.BLUE
	
	#temp
	if instance.team == Enums.Team.BLUE:
		instance.modulate = Color(0,0,255)
		instance.damage_priority = 0
	elif instance.team == Enums.Team.RED:
		instance.modulate = Color(255,0,0)
		instance.damage_priority = 1
	
	my_boids.append(instance)
	add_child(instance)
	instance.reparent(boid_node)

func _on_spawn_timer_timeout() -> void:
	create_boid()
