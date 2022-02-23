extends Control

var direction: Vector2i = Vector2i.RIGHT
var length: int = 0

var current_mouse_pos: Vector2i = Vector2i.ZERO

var ship_number_button_scene = preload("res://ship_placement/ship_number_button.tscn")

@onready var ship_number_buttons = $VBoxContainer/HBoxContainer/VBoxContainer/ShipNumberButtons


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


func _field_pressed(x: int, y: int, button: int, player: String) -> void:
	print(x, " ", y)
	if button == MOUSE_BUTTON_LEFT and Global.can_place(x, y, direction, length):
		Global.place(x, y, direction, length)
	elif button == MOUSE_BUTTON_RIGHT:
		Global.remove(x, y)
	Signals.board_updated.emit(player, Global.board, Global.parse_hover(x, y, direction, length))
	update_ship_quantity()


func _field_hovered(x: int, y: int, player: String) -> void:
	Signals.board_updated.emit(player, Global.board, Global.parse_hover(x, y, direction, length))
	current_mouse_pos.x = x
	current_mouse_pos.y = y


func _length_selected(val: int) -> void:
	length = val


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate"):
		if direction == Vector2i.RIGHT:
			direction = Vector2i.DOWN
		else:
			direction = Vector2i.RIGHT
		Signals.board_updated.emit(Network.nickname, Global.board,
									Global.parse_hover(current_mouse_pos.x, current_mouse_pos.y,
									direction, length))
