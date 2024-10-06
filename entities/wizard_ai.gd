extends Wizard

func wizard_ready():
	pass

func wizard_process(delta):
	if battlefield and battlefield.player:
		look_at(battlefield.player.global_position)
