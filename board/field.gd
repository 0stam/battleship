extends TextureRect
# Uses custom button logic, necessary for identyfying the left/right mouse button presses

signal pressed(x: int, y: int, mouse_button: int)

# Stores mouse buttons states to be able to activate only on release in the button's area
var buttons_pressed: Array[bool] = [false, false]


func _on_field_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index < 3:
		if event.pressed:
			buttons_pressed[event.button_index - 1] = true
		else:
			if buttons_pressed[event.button_index - 1]:
				# The button's name should be equal to its position in the grid
				var position: PackedStringArray = str(name).split(" ")
				pressed.emit(position[0].to_int(), position[1].to_int(), event.button_index)
			buttons_pressed[event.button_index - 1] = false


func _on_field_mouse_exited() -> void:
	buttons_pressed[0] = false
	buttons_pressed[1] = false
