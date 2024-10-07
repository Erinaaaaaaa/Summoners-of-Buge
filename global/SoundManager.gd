extends Node






# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func play_sound(sound : AudioStream, randomness : float = 1):
	if !sound: 
		print("Sfx call with no sound")
		print(sound)
		return
	
	var instance = AudioStreamRandomizer.new()
	instance.random_pitch = randomness
	instance.add_stream(0,sound)
	
	var player_instance = AudioStreamPlayer.new()
	player_instance.stream = instance
	player_instance.finished.connect(player_done.bind(player_instance))
	add_child(player_instance)
	player_instance.play()
	pass
	
func player_done(player_instance : AudioStreamPlayer):
	player_instance.queue_free()
	pass
