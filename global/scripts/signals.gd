extends Node

signal field_pressed(x: int, y: int, mouse_button: int, player: String)
signal field_hovered(x: int, y: int, player: String)

signal board_updated(player: String, board: Array[Array], hover: Array[Array])
