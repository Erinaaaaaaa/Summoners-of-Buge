extends Wizard


func wizard_ready():
	type = Enums.Player.PLAYER
	pass

func wizard_process(delta):
	if battlefield and !battlefield.player:
		battlefield.player = self
	
	look_at(get_viewport().get_mouse_position())
