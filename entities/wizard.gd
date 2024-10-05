extends Area2D
class_name Wizard

@export var team = Enums.Team.RED
@export var pool_area : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if team == Enums.Team.RED:
		pool_area.add_to_group("red_pool_area")
	if team == Enums.Team.BLUE:
		pool_area.add_to_group("blue_pool_area")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
