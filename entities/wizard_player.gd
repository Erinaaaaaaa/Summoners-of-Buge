extends Wizard


func wizard_ready():
	pass

func wizard_process(delta):
	if battlefield and !battlefield.player:
		battlefield.player = self
	
	look_at(get_viewport().get_mouse_position())

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			for i in range(5):
				var p = ParticlesManager.create_particle("cloud", battlefield)
				p.rotation_degrees = randf_range(0,360)
				p.global_position = event.position
				
			cast("spawn_weak_boids",event.position)
