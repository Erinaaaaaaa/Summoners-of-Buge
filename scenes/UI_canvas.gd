extends CanvasLayer

@export var combat_result : Label


func _on_button_try_again_button_down():
	get_tree().change_scene_to_file("res://scenes/battlefield.tscn")


func _on_button_menu_button_down():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
