extends Control

@export var decoy_left_label : Label
@export var spee_left_label : Label
@export var snipe_left_label : Label
@export var spidler_left_label : Label

@export var battlefield : Node

func _process(delta):
	decoy_left_label.text = str(battlefield.player.casts_left["decoy"])
	spee_left_label.text = str(battlefield.player.casts_left["spee"])
	snipe_left_label.text = str(battlefield.player.casts_left["snipe"])
	spidler_left_label.text = str(battlefield.player.casts_left["spidler"])
