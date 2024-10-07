extends Node2D


func _ready():
	$"CanvasLayer/UI/CreditsPanel/Control/Monito-1".play()

func _on_start_button_button_down():
	get_tree().change_scene_to_file("res://scenes/battlefield.tscn")


func _on_show_instructions_button_down():
	$CanvasLayer/UI/InstructionsPanel.visible = true
	$CanvasLayer/UI/ShowCredits.disabled = true


func _on_return_to_menu_button_down():
	$CanvasLayer/UI/CreditsPanel.visible = false
	$CanvasLayer/UI/ShowCredits.disabled = false


func _on_show_credits_button_down():
	$CanvasLayer/UI/CreditsPanel.visible = true
	$CanvasLayer/UI/ShowCredits.disabled = true
