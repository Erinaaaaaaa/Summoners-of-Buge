extends Wizard


func wizard_ready():
	type = Enums.Player.PLAYER
	if battlefield and !battlefield.player:
		battlefield.player = self

func wizard_process(delta):
	if battlefield and !battlefield.player:
		battlefield.player = self
	
	look_at(get_viewport().get_mouse_position())

func _input(event):
	if !GameManager.is_game_running: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if can_dash:
				dash(rotation)
			else:
				var p = ParticlesManager.create_particle("tooltip", battlefield)
				p.position = global_position
				p.label.text = "Dash recharging!"
			
