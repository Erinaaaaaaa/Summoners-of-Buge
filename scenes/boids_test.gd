extends Node2D

@export var boid_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	for i in range(10):
		var added : Boid = add_boid(Vector2(randi_range(100, 1100),randi_range(100, 600)))


func add_boid(position):
	var boid_i = boid_scene.instantiate()
	boid_i.position = position
	
	print("Added " + str(boid_i))
	add_child(boid_i)
	
	return boid_i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
