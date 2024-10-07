extends Node2D


func _ready():
	$"CanvasLayer/UI/Monito-1".play()

func _on_start_button_button_down():
	get_tree().change_scene_to_file("res://scenes/battlefield.tscn")
