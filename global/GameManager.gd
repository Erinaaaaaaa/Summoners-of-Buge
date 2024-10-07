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
	
	battlefield.ui_canvas.visible = true
	
	match player:
		Enums.Player.PLAYER:
			battlefield.anim_camera("playerDeath")
			battlefield.on_game_over(false)
			battlefield.ui_canvas.combat_result.text = "Enemy "
		Enums.Player.AI:
			battlefield.anim_camera("aiDeath")
			battlefield.on_game_over(true)
			battlefield.ui_canvas.combat_result.text = "Player "
	
	battlefield.ui_canvas.combat_result.text += "Won!"
	
	is_game_running = false
 
