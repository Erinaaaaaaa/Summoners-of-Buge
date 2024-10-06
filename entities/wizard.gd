extends Area2D
class_name Wizard

#--- Exported vars ---
@export_category("Properties")
@export var team = Enums.Team.RED

@export_category("Prefabs")
@export var max_mana = 6
@export var mana_scene : PackedScene

@export var isPlayer : bool

@export var battlefield : Battlefield


#--- Non-inspector exposed vars ---
var my_boids = []
var mana = max_mana

var player_wizard : Wizard

var mana_display_instances = []
var animation_time = 0

var mana_distance = 100

var hood_sprite = preload("res://sprites/wizard/wiz_hood.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	#if team == Enums.Team.RED:
		#pool_area.add_to_group("red_pool_area")
	#if team == Enums.Team.BLUE:
		#pool_area.add_to_group("blue_pool_area")
		
	if !isPlayer:
		$Sprite.texture = hood_sprite
		player_wizard = get_parent().get_node("Wizard") #HARDCODED PLAYER ASSIGNMENT
	else:
		player_wizard = self
		pass
	
	init_mana()
	$SpawnTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if isPlayer:
		control_player()
	else:
		ai_enemy()
		
	render_mana()
	pass
	
func _input(event):
	# Do nothing if it's not the player
	if !isPlayer: return
	
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			for i in range(5):
				var p = ParticlesManager.create_particle("cloud", battlefield)
				p.rotation_degrees = randf_range(0,360)
				p.global_position = event.position
				
			battlefield.add_boid("boid_neutral", team, event.position)

func control_player():
	look_at(get_viewport().get_mouse_position())
	pass
	
func ai_enemy():
	look_at(player_wizard.global_position)
	pass

func cast_spawn_boid():
	pass

func init_mana() -> void:
	while mana_display_instances.size() < max_mana:
		var mana_instance = mana_scene.instantiate()
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

func _on_spawn_timer_timeout() -> void:
	#create_boid()
	return
	
