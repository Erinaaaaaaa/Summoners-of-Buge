extends Node2D
class_name Battlefield

var boids = []
var max_boids = 120

var player : Wizard

@export var music_player : AudioStreamPlayer2D
@export var win_music : AudioStream
@export var lose_music : AudioStream

@export var ui_canvas : CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.battlefield = self
	GameManager.is_game_running = true
	music_player.play()

func add_boid(boid_type : String, team : Enums.Team, position : Vector2, rotation):
	if  boids.size() >= max_boids:
		print("Max entities reached. Can't create a new boid.")
		return null
	
	var boid_i : Boid = ResourcesManager.create_instance("boid_neutral") as Boid
	boid_i.position = position
	boid_i.global_rotation = rotation
	
	# Set settings
	var boid_settings = ResourcesManager.spell_data[boid_type]["options"]
	boid_i.max_speed = boid_settings["max_speed"]
	boid_i.damage_priority = boid_settings["damage_priority"]
	boid_i.lifetime = boid_settings["lifetime"]
	boid_i.set_sprite(boid_settings["sprite"])
	boid_i.set_team(team)
	match team:
		Enums.Team.RED: #AI
			boid_i.wizard_node = $WizardPlayer
		Enums.Team.BLUE: #Player
			boid_i.wizard_node = $WizardAI
	
	boid_i.connect("deleted", boid_deleted)
	print("Added " + str(boid_i))
	$Boids.add_child(boid_i)
	boids.append(boid_i)
	
	for i in range(2):
		var p = ParticlesManager.create_particle("cloud", self)
		p.rotation_degrees = randf_range(0,360)
		p.global_position = position
	
	return boid_i
		
func boid_deleted(boid : Boid):
	boids.erase(boid)


func on_game_over(has_won : bool):
	if has_won:
		music_player.stream = win_music
	else:
		music_player.stream = lose_music
	
	music_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spell_button_down(spell_name):
	player.cast(spell_name, player.position)
	
func anim_camera(animation):
	print("battlefield anim camera")
	$Camera2D/CameraAnimation.play(animation)


func _on_music_finished():
	if GameManager.is_game_running:
		music_player.play()
