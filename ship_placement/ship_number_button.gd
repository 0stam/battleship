@tool
extends Button

signal length_selected(val: int)

@onready var length_label: Label = $HBoxContainer/Length
@onready var quantity_label: Label = $HBoxContainer/Quantity

@export var length: int = 0:
	set(val):
		length = val
		if length_label:
			if length > 1: length_label.text = str(length) + " fields:"
			else: length_label.text = str(length) + " field:"
@export var quantity: int = 0:
	set(val):
		quantity = val
		if quantity_label: quantity_label.text = str(val)


func _ready() -> void:
	# Use setters if they were not automatically triggered at ready
	length = length
	quantity = quantity


func _on_ship_number_button_toggled(button_state: bool) -> void:
	if button_state:
		length_selected.emit(length)
		get_tree().call_group("ship_number_buttons", StringName("disable"), length)
	else:
		set_pressed_no_signal(true)


func disable(exception: int):  # Should be called on group
	set_pressed_no_signal(length == exception)


func update_quantity(target_length: int, val: int):  # Should be called on group
	if target_length == length:
		quantity = val
