extends Area2D
class_name Wizard

#--- Exported vars ---
@export_category("Properties")
@export var team = Enums.Team.RED
@export var pool_area : Area2D
@export var boid_node : Node2D

@export_category("Prefabs")
@export var boid_scene : PackedScene

@export var max_mana = 6
@export var mana_scene : PackedScene

@export var isPlayer : bool


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
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			global_position = event.position
			
			for i in range(5):
				var p = ParticlesManager.create_particle("cloud", self)
				p.rotation_degrees = randf_range(0,360)
				
			
			print("Mouse Click at: ", event.position)

func control_player():
	look_at(get_viewport().get_mouse_position())
	pass
	
func ai_enemy():
	look_at(player_wizard.global_position)
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
	
