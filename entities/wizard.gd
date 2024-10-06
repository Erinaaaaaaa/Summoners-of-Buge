extends Area2D
class_name Wizard

#--- Exported vars ---
@export_category("Properties")
@export var team = Enums.Team.RED

@export_category("Prefabs")
@export var max_mana = 6

@export var battlefield : Battlefield


#--- Non-inspector exposed vars ---
var my_boids = []
var mana = max_mana

var player_wizard : Wizard

var mana_display_instances = []
var animation_time = 0

var mana_distance = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	wizard_ready()
	
	init_mana()
	$SpawnTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wizard_process(delta)
	render_mana()

func init_mana() -> void:
	while mana_display_instances.size() < max_mana:
		var mana_instance = ResourcesManager.create_instance("mana_ball")
		mana_instance.position = global_position
		add_child(mana_instance)
		mana_display_instances.append(mana_instance)
	return

func render_mana() -> void:
	animation_time += 1
	for m in range(max_mana) :
		if m <= mana-1 :
			mana_display_instances[m].visible = true
			mana_display_instances[m].global_position = lerp(mana_display_instances[m].global_position,circle_around(global_position,mana_distance,(m+1/max_mana)+animation_time*0.01),0.1)
			
		else:
			mana_display_instances[m].visible = false
			mana_display_instances[m].position = global_position
	return
	
func circle_around(pivot:Vector2, distance:float, offset:float) -> Vector2: 
	return pivot + Vector2(cos(offset),sin(offset))*distance

## Functions used by player/AI

func cast_spawn_boid(boid_type : String, team : Enums.Team, position : Vector2):
	battlefield.add_boid(boid_type, team, position)
##



## Functions used by children classes

func wizard_ready(): pass
func wizard_process(delta): pass

##
