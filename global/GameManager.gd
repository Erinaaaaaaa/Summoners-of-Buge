extends Node

enum GameState {
	MENU,
	PLAYING,
	GAMEOVER
}

# --- Game ---
var battlefield: Battlefield
var is_game_running: bool

func gameover(player: Enums.Player):
	match player:
		Enums.Player.PLAYER:
			battlefield.anim_camera("playerDeath")
			battlefield.on_game_over(false)
		Enums.Player.AI:
			battlefield.anim_camera("aiDeath")
			battlefield.on_game_over(true)
			
	is_game_running = false
 
