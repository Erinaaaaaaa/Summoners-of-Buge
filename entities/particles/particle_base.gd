extends Node2D
class_name ParticleBase

@export var animation_player : AnimationPlayer

func _ready():
	if !animation_player:
		print("ERROR: Animation player not set in particle scene.")
		return
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	
	animation_player.stop()
	animation_player.play("play")



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "play":
		queue_free()
