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

var casts_left = {
	"spawn_weak_boids":20
}

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
			mana_display_instances[m].global_position = lerp(mana_display_instances[m].global_position,circle_around(global_position,mana_distance,((m+1)*PI*2/mana)+animation_time*0.01),0.1)
			
		else:
			mana_display_instances[m].visible = false
			mana_display_instances[m].position = global_position
	return
	
func circle_around(pivot:Vector2, distance:float, offset:float) -> Vector2: 
	return pivot + Vector2(cos(offset),sin(offset))*distance

## Functions used by player/AI


func cast(spell_name : String, pos : Vector2):
	
	# Casts a COUNT number of times the spell specified by the name.
	# Stops or doesn't do it if there's not more casts allowed for now.
	
	# Can't even find the spell data in the manager.
	if !ResourcesManager.spell_data.has(spell_name):
		print("ERROR: Spell of name '" + spell_name + " not found.")
		return
	
	# The spell data exists, but not recognized as a spell the wizard can cast.
	if !casts_left.has(spell_name):
		print("ERROR: Wizard doesn't seem to be able to cast the spell '"+ spell_name + "'.")
	
		
	var spell_data = ResourcesManager.spell_data[spell_name]
	var cast_count = spell_data["count"]
	
	# Can't cast any more at all.
	if casts_left[spell_name] <= 0:
		print("Can't cast spell anymore!") # Replace it with an animation or function eventualy
		return
	
	var spell_cost = spell_data["cost"]
	var summon_pivot = ((pos - global_position).normalized() * 120) + global_position #"arm" length
	
	# Drain the mana first
	gain_mana(-spell_cost)
	
	# Cast the number of spells needed
	var i = min(casts_left[spell_name], cast_count)
	while i > 0:
		var summon_pos = circle_around(summon_pivot,30*pow(i,0.5),((i+1)*PI*2)/6)
		cast_spawn_boid("boid_neutral",summon_pos,summon_pivot.angle_to_point(pos))
		i -= 1

	# Update the casts left
	casts_left[spell_name] -= cast_count
	if casts_left[spell_name] < 0: casts_left[spell_name] = 0
	

func cast_spawn_boid(boid_name, pos, rot):
	battlefield.add_boid(boid_name, team, pos)
	pass

func die():
	wizard_on_death()
	print("Wizard " + str(self) + "Fucking died!!!!!!")

func gain_mana(val):
	if (mana + val) > max_mana:
		mana = max_mana
	if (mana + val) < 0 :
		mana = 0
		die()
	else:
		mana += val
	pass

##



## Functions used by children classes

func wizard_ready(): pass
func wizard_process(delta): pass
func wizard_on_death(): pass

##
