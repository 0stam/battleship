extends Node

signal field_pressed(coords: Vector2i, mouse_button: int, player: String)
signal field_hovered(coords: Vector2i, player: String)

signal board_updated(player: String, board: Array, hover: Array)

signal player_list_updated(players: Array[String])

signal chat_history_updated(chat_history: Array)

signal field_hit(x: int, y: int, player: String)


@rpc(any_peer, call_local)
func register_board_update(player: String, board: Array, hover: Array):
	board_updated.emit(player, board, hover)
