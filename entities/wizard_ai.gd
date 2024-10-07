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
	
	var enemy_boids = check_boids_around()["enemy_boids"]
	if enemy_boids.size() > 3:
		if can_dash:
			#Dash in a perpendicular direction regarding the average of the dangerous boids
			var avg_angle = 0
			for b in enemy_boids: avg_angle += global_position.angle_to_point(b.global_position)
			avg_angle /= enemy_boids.size()
			dash(avg_angle + PI/2, false)
	
	# 1/400 chance every frame to dash towards player
	if can_dash:
		if randi()%100 == 0:
			dash(rotation, false)
	
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
