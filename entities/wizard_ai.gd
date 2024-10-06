extends Wizard

var cast_spell_cooldown = 3
var timer = 0
var next_spell = "decoy"

func wizard_ready():
	type = Enums.Player.AI
	choose_next_spell()

func wizard_process(delta):
	if battlefield and battlefield.player:
		look_at(battlefield.player.global_position)
	
	
	timer += delta
	if timer > cast_spell_cooldown and can_cast_spell(next_spell):
		timer = 0
		cast(next_spell, global_position)
		choose_next_spell()
			

func choose_next_spell():
	if randi()%2 == 0:
		next_spell = "spee"
	else:
		next_spell = "decoy"
