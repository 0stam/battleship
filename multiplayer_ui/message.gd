@tool
extends Panel

@export var nickname: String = "":
	set(val):
		nickname = val
		if name_label: name_label.text = val
@export var content: String = "":
	set(val):
		content = val
		if content_label:
			content_label.text = val
			await get_tree().process_frame  # Wait for the text wrapping to happen
			rect_min_size.y = content_label.rect_size.y

@onready var name_label: Label = $HBoxContainer/Name
@onready var content_label: Label = $HBoxContainer/Content


func _ready() -> void:
	# Trigger setter functions when children are ready, required for tool script
	nickname = nickname
	content = content
