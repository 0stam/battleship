extends Control

const graphics = {
	Field.EMPTY: null,
	Field.HIT: preload("res://art/tile_graphics/hit.png"),
	Field.SHIP: preload("res://art/tile_graphics/ship.png"),
	Field.HIT_SHIP: preload("res://art/tile_graphics/hit_ship.png"),
	Field.SUNK_SHIP: preload("res://art/tile_graphics/sunk_ship.png")
}

var board_button_scene = preload("res://board/field.tscn")

var board = []  # Contains contents of each field, 2D list should be created here
var player_name: String:
	set(val):
		player_name = val
		player_name_label.text = val

@onready var border: NinePatchRect = $AspectRatioContainer/VBoxContainer/Stack/Border
@onready var tiles: GridContainer = $AspectRatioContainer/VBoxContainer/Stack/Tiles
@onready var fields: GridContainer = $AspectRatioContainer/VBoxContainer/Stack/Fields
@onready var player_name_label = $AspectRatioContainer/VBoxContainer/PlayerName


func _ready() -> void:
	# Fill grid with buttons
	for y in 10:
		for x in 10:
			var button: TextureRect = board_button_scene.instantiate()
			button.name = str(x) + " " + str(y)
			button.pressed.connect(_field_pressed)
			fields.add_child(button)
	
	# Create 2D list of empty fields
	for i in 10:
		board.append([])
		for j in 10:
			board[i].append(Field.EMPTY)
	
#	for i in range(2, 6):
#		set_field_graphic(i, 3, Field.SHIP)
#	set_field_graphic(3, 3, Field.HIT_SHIP)
#	set_field_graphic(3, 4, Field.HIT)
#	set_field_graphic(3, 2, Field.HIT)
#	for i in range(5, 9):
#		set_field_graphic(7, i, Field.SUNK_SHIP)
#	for i in range(1, 4):
#		set_field_graphic(i, 7, Field.SHIP)


func set_frame_size() -> void:
	# Set border size
	var frame_size: int = 0
	if rect_size.x < rect_size.y * 0.921:
		frame_size = int(round(rect_size.x * 0.00704))
	else:
		frame_size = int(round(rect_size.y * 0.00691))
	border.patch_margin_left = frame_size
	border.patch_margin_right = frame_size
	border.patch_margin_top = frame_size
	border.patch_margin_bottom = frame_size
	
	# Workaround for grid container not scaling children with sub-pixel values
	# Make border smaller manually
	await get_tree().process_frame  # Wait for children to update
	
	var space_x: int = 0  # Space between right edge of the frame in pixels
	space_x = border.rect_size.x - 10 * tiles.get_child(0).rect_size.x - border.offset_right
	border.offset_right = -space_x
	
	var space_y: int = 0  # Space between bottom edge of the frame in pixels
	space_y = border.rect_size.y - 10 * tiles.get_child(0).rect_size.y - border.offset_bottom
	border.offset_bottom = -space_y


func set_field_graphic(x: int, y: int, type: int):
	fields.get_node(str(x) + " " + str(y)).texture = graphics[type]


func _on_board_item_rect_changed() -> void:
	set_frame_size()


func _field_pressed(x: int, y: int, button: int):
	print(x, " ", y, " ", button)
