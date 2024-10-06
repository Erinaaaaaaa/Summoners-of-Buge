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
	is_game_running = false
	match player:
		Enums.Player.PLAYER:
			battlefield.anim_camera("playerDeath")
		Enums.Player.AI:
			battlefield.anim_camera("aiDeath")
 
