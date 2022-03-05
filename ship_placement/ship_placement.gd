extends Control

var direction: Vector2i = Vector2i.RIGHT
var length: int = 0

var current_mouse_pos: Vector2i = Vector2i.ZERO
var players_ready: int = 0

var ship_number_button_scene = preload("res://ship_placement/ship_number_button.tscn")

@onready var ship_number_buttons = $VBoxContainer/HBoxContainer/VBoxContainer/ShipNumberButtons
@onready var ready_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/ReadyButton



func _ready() -> void:
	# Recreate buttons according to current rules
	for node in ship_number_buttons.get_children():
		ship_number_buttons.remove_child(node)
	for length in Global.rules["ship_number"]:
		var button: Button = ship_number_button_scene.instantiate()
		button.length = length
		button.quantity = Global.rules["ship_number"][length]
		button.length_selected.connect(_length_selected)
		ship_number_buttons.add_child(button)
	ship_number_buttons.get_child(0).button_pressed = true
	length = ship_number_buttons.get_child(0).length
	
	Global.initialize_board()
	
	Signals.field_pressed.connect(_field_pressed)
	Signals.field_hovered.connect(_field_hovered)


func update_ship_quantity():
	var ship_quantity = Global.get_ship_count()
	for length in ship_quantity:
		get_tree().call_group(StringName("ship_number_buttons"), StringName("update_quantity"),
								length, Global.rules["ship_number"][length] - ship_quantity[length])


@rpc(any_peer, call_local)
func register_ready() -> void:
	players_ready += 1
	if players_ready >= 3 and multiplayer.is_server():
		Network.rpc(StringName("change_scene"), "res://main/main.tscn", true)


func _field_pressed(coords: Vector2i, button: int, player: String) -> void:
	print(coords.x, " ", coords.y)
	if button == MOUSE_BUTTON_LEFT and Global.can_place(coords, direction, length):
		Global.place(coords, direction, length)
	elif button == MOUSE_BUTTON_RIGHT:
		Global.remove(coords)
	Signals.register_board_update(player, Global.board, Global.parse_hover(coords, direction, length))
	update_ship_quantity()


func _field_hovered(coords: Vector2i, player: String) -> void:
	Signals.register_board_update(player, Global.board, Global.parse_hover(coords, direction, length))
	current_mouse_pos.x = coords.x
	current_mouse_pos.y = coords.y


func _length_selected(val: int) -> void:
	length = val


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate"):
		if direction == Vector2i.RIGHT:
			direction = Vector2i.DOWN
		else:
			direction = Vector2i.RIGHT
		Signals.register_board_update(Network.nickname, Global.board,
										Global.parse_hover(current_mouse_pos, direction, length))


func _on_ready_button_pressed() -> void:
	var ship_quantity: Dictionary = Global.get_ship_count()
	for length in ship_quantity:
		if ship_quantity[length] < Global.rules["ship_number"][length]:
			return
	rpc(StringName("register_ready"))
	ready_button.disabled = true
	ready_button.text = "Waiting for other players"
	
