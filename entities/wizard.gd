extends Area2D
class_name Wizard

#--- Exported vars ---
@export_category("Properties")
@export var team = Enums.Team.RED

@export_category("Prefabs")
@export var max_mana = 6

@export var battlefield : Battlefield

@export_category("Sounds")

@export var mana_up :AudioStream
@export var mana_down :AudioStream
@export var wizard_hurt :AudioStream
@export var wizard_death :AudioStream
@export var fail_cast :AudioStream
@export var no_cast :AudioStream

#--- Non-inspector exposed vars ---
var mana = max_mana

var player_wizard : Wizard

var mana_display_instances = []
var animation_time = 0
var type: Enums.Player

var mana_distance = 100
var invincible = false

var casts_left = {
	"decoy": 8*4,
	"spee": 3*5
}



# Called when the node enters the scene tree for the first time.
func _ready():
	wizard_ready()
	
	init_mana()
	$ManaRechargeTimer.start()

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
		return
	
	if !can_cast_spell(spell_name): 
		SoundManager.play_sound(fail_cast,1.2)
		return
	
		
	var spell_data = ResourcesManager.spell_data[spell_name]
	var cast_count = spell_data["count"]
	
	# Can't cast any more at all.
	if casts_left[spell_name] <= 0:
		SoundManager.play_sound(no_cast,1.2)
		print("Can't cast spell anymore!") # Replace it with an animation or function eventualy
		return
	
	var spell_cost = spell_data["cost"]
	var summon_pivot = ((pos - global_position).normalized() * 120) + global_position #"arm" length
	
	# Drain the mana first
	gain_mana(-spell_cost)
	
	#Play the spells cast sound
	SoundManager.play_sound(load(spell_data["sound"]),1.4)
	
	# Cast the number of spells needed
	var i = min(casts_left[spell_name], cast_count)
	while i > 0:
		var summon_pos = circle_around(summon_pivot,30*pow(i,0.5),((i+1)*PI*2)/6)
		var boid = cast_spawn_boid(spell_name,summon_pos,summon_pivot.angle_to_point(pos))
		boid.type = spell_name
		boid.connect("deleted", boid_killed)
		i -= 1

	# Update the casts left
	casts_left[spell_name] -= cast_count
	if casts_left[spell_name] < 0: casts_left[spell_name] = 0
	

func can_cast_spell(spell_name : String):
	if !ResourcesManager.spell_data.has(spell_name):
		print("ERROR: Spell of name '" + spell_name + " not found.")
		return false
	
	# The spell data exists, but not recognized as a spell the wizard can cast.
	if !casts_left.has(spell_name):
		return false
		
	var spell_data = ResourcesManager.spell_data[spell_name]
	
	# You can't case the spell if you don't have enough mana.
	if mana < spell_data["cost"]: return false
	
	# You can't cast the spell if you don't have any cast left on that spell.
	if casts_left[spell_name] <= 0: return false
	
	# You can't cast the spell if the spell isn't charged yet
	# NOT IMPLEMENTED YET
	
	return true

func cast_spawn_boid(boid_name, pos, rot):
	
	return battlefield.add_boid(boid_name, team, pos)

func boid_killed(boid:Boid):
	casts_left[boid.type] += 1

func die():
	wizard_on_death()
	SoundManager.play_sound(wizard_death,1.2)
	print("Wizard " + str(self) + " Fucking died!!!!!!")
	$AnimationPlayer.play("death")
	print($AnimationPlayer.current_animation)
	GameManager.gameover(type)

func gain_mana(val):
	mana += val
	
	if mana > max_mana:
		mana = max_mana
	
	if (mana) < 0 :
		mana = -1
		die()


func hit():
	if invincible:
		return
	invincible = true
	gain_mana(-2)
	if (mana >= 0):
		$AnimationPlayer.play("invincibility")
##



## Functions used by children classes

func wizard_ready(): pass
func wizard_process(delta): pass
func wizard_on_death(): pass

##


func _on_mana_recharge_timer_timeout():
	SoundManager.play_sound(mana_up,1.4)
	gain_mana(1)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "invincibility":
		invincible = false
