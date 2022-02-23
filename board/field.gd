extends TextureRect
# Uses custom button logic, necessary for identyfying the left/right mouse button presses

signal pressed(x: int, y: int, mouse_button: int)
signal hovered(x: int, y: int)

# Stores mouse buttons states to be able to activate only on release in the button's area
var buttons_pressed: Array[bool] = [false, false]


func parse_position() -> Vector2i:
	var result: PackedStringArray = str(name).split(" ")
	return Vector2i(result[0].to_int(), result[1].to_int())


func _on_field_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index < 3:
		if event.pressed:
			buttons_pressed[event.button_index - 1] = true
		else:
			if buttons_pressed[event.button_index - 1]:
				# The button's name should be equal to its position in the grid
				var position: Vector2i = parse_position()
				pressed.emit(position.x, position.y, event.button_index)
			buttons_pressed[event.button_index - 1] = false


func _on_field_mouse_exited() -> void:
	buttons_pressed[0] = false
	buttons_pressed[1] = false


func _on_field_mouse_entered() -> void:
	hovered.emit(parse_position().x, parse_position().y)
