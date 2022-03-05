extends Node

var rules: Dictionary = {
	"ship_number": {4: 1, 3: 2, 2: 3, 1: 4},  # Number of ships of specific sizes
	"continue_on_hit": false  # Makes player continue his turn after hitting enemy ship, *unimplemented*
}

var board: Array[Array] = []


func get_field(coords: Vector2i) -> int:
	return board[coords.x][coords.y]


func set_field(coords: Vector2i, value: int) -> void:
	board[coords.x][coords.y] = value


func initialize_board() -> void:
	board.clear()
	for i in 10:
		board.append([])
		for j in 10:
			board[i].append(Field.EMPTY)


func is_invalid(coords: Vector2i) -> bool:
	if coords.x >= len(board) or coords.x < 0:
		return true
	if coords.y >= len(board[0]) or coords.y < 0:
		return true
	return false


func can_place(coords: Vector2i, direction: Vector2i, length: int) -> bool:
	# If selection would go out of bounds
#	if is_invalid(x + clamp(direction.x * length - 1, 0, 10),
#					y + clamp(direction.y * length - 1, 0, 10)):
#		return false
	if is_invalid(coords + direction * (length - 1)):
		return false
	
	var ship_quantity: Dictionary = get_ship_count()
	if length in ship_quantity and rules["ship_number"][length] - ship_quantity[length] <= 0:
		return false
	
	# If there is already a ship there
	for i in length:
		var current: Vector2i = coords + direction * i
		
		if get_field(current) != Field.EMPTY:
			return false
		
		for j in range(-1, 2):
			for k in range(-1, 2):
				var current_pos: Vector2i = current + Vector2i(j, k)
				if is_invalid(current_pos):
					break
				if get_field(current_pos) != Field.EMPTY:
					return false
	return true


func place(coords: Vector2i, direction: Vector2i, length: int) -> void:
	for i in length:
		set_field(coords + direction * i, Field.SHIP)


func remove(coords):
	if is_invalid(coords):
		return
	if get_field(coords) == Field.EMPTY:
		return
	
	set_field(coords, Field.EMPTY)
	for i in range(-1, 2):
		for j in range(-1, 2):
			remove(coords + Vector2i(i, j))


func get_length_in_direction(coords: Vector2i, direction: Vector2i) -> int:
	var i: int = 1
	while true:
		var current: Vector2i = coords + direction * i
		if is_invalid(current):
			return i - 1
		if get_field(current) == Field.EMPTY:
			return i - 1
		i += 1
	return i - 1


func get_ship_length(coords: Vector2i) -> int:
	if get_field(coords) == Field.EMPTY:
		return 0
	
	var length: int = 1
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
	for direction in directions:
		length += get_length_in_direction(coords, direction)
	
	return length


func get_ship_count() -> Dictionary:
	var board_copy: Array[Array] = board.duplicate(true)
	var ship_count: Dictionary = {}
	for key in Global.rules["ship_number"]:
		ship_count[key] = 0
	
	for x in 10:
		for y in 10:
			var length: int = get_ship_length(Vector2i(x, y))
			if length:
				remove(Vector2i(x, y))
				ship_count[length] += 1
	board = board_copy
	return ship_count


func parse_hover(coords: Vector2i, direction: Vector2i, length: int) -> Array[Array]:
	var result = []
	for i in 10:
		result.append([])
		for j in 10:
			result[i].append(Field.EMPTY)
	
	for i in length:
		var pos: Vector2i = coords + direction * i
		if is_invalid(pos):
			break
		result[pos.x][pos.y] = Field.SHIP
	
	return result


func can_hit(coords: Vector2i) -> bool:
	return get_field(coords) == Field.EMPTY or get_field(coords) == Field.SHIP


func sink_direction(coords: Vector2i, direction: Vector2i) -> void:
	var i: int = 0
	while true:
		var position: Vector2i = coords + direction * i
		if is_invalid(position):
			return
		if get_field(position) == Field.EMPTY:
			return
		if get_field(position) == Field.HIT:
			return
		set_field(position, Field.SUNK_SHIP)
		i += 1


func hit(coords) -> void:
	match get_field(coords):
		Field.EMPTY:
			set_field(coords, Field.HIT)
		Field.SHIP:
			set_field(coords, Field.HIT_SHIP)
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
	for dir in directions:
		sink_direction(coords, dir)
