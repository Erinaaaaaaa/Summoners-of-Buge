extends Node2D
class_name Battlefield

var boids = []
var max_boids = 120

var player : Wizard

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(100):
		pass #add_boid("boid_neutral", Enums.Team.RED, Vector2(randf_range(0,1000),randf_range(0,500)))


func add_boid(boid_type : String, team : Enums.Team, position : Vector2):
	if  boids.size() >= max_boids:
		print("Max entities reached. Can't create a new boid.")
		return null
	
	var boid_i : Boid = ResourcesManager.create_instance("boid_neutral") as Boid
	boid_i.position = position
	boid_i.rotation_degrees = randf_range(0,360)
	
	# Set settings
	var boid_settings = ResourcesManager.spell_data[boid_type]["options"]
	boid_i.max_speed = boid_settings["max_speed"]
	boid_i.damage_priority = boid_settings["damage_priority"]
	boid_i.lifetime = boid_settings["lifetime"]
	boid_i.set_sprite(boid_settings["sprite"])
	
	boid_i.connect("deleted", boid_deleted)
	print("Added " + str(boid_i))
	$Boids.add_child(boid_i)
	boids.append(boid_i)
	
	return boid_i
		
func boid_deleted(boid : Boid):
	boids.erase(boid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#for b in boids:
		#b.steer_towards = get_local_mouse_position()
	#
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#add_boid(get_local_mouse_position())
		pass


func _on_spell_button_down(spell_name):
	player.cast(spell_name, player.position)
