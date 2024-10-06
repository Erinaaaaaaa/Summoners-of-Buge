extends Node2D

@export var boid_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	for i in range(50): # Preys
		var added : Boid = add_boid(Vector2(randi_range(100, 500),randi_range(100, 600)))
		added.set_team(Enums.Team.BLUE)
		added.damage_priority = 0
		added.max_speed = 300
		
	for i in range(5): # Predators
		var added : Boid = add_boid(Vector2(randi_range(700, 1200),randi_range(100, 600)))
		added.set_team(Enums.Team.RED)
		added.set_sprite("spee")
		added.damage_priority = 1
		added.max_speed = 400


func add_boid(position):
	var boid_i = boid_scene.instantiate()
	boid_i.position = position
	
	print("Added " + str(boid_i))
	add_child(boid_i)
	
	return boid_i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
