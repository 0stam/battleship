extends Node

var rules: Dictionary = {
	"ship_number": {4: 1, 3: 2, 2: 3, 1: 4},  # Number of ships of specific sizes
	"continue_on_hit": false  # Makes player continue his turn after hitting enemy ship, *unimplemented*
}

var board: Array[Array] = []


func initialize_board() -> void:
	board.clear()
	for i in 10:
		board.append([])
		for j in 10:
			board[i].append(Field.EMPTY)


func is_invalid(x: int, y: int) -> bool:
	if x >= len(board) or x < 0:
		return true
	if y >= len(board[0]) or y < 0:
		return true
	return false


func can_place(x: int, y: int, direction: Vector2i, length: int) -> bool:
	# If selection would go out of bounds
	if is_invalid(x + clamp(direction.x * length - 1, 0, 10),
					y + clamp(direction.y * length - 1, 0, 10)):
		return false
		
	var ship_quantity: Dictionary = get_ship_count()
	if length in ship_quantity and rules["ship_number"][length] - ship_quantity[length] <= 0:
		return false
	
	# If there is already a ship there
	for i in length:
		var current_x: int = x + direction.x * i
		var current_y: int = y + direction.y * i
		
		if board[current_x][current_y] != Field.EMPTY:
			return false
		
		for j in range(-1, 2):
			for k in range(-1, 2):
				if is_invalid(current_x + j, current_y + k):
					continue
				if board[current_x + j][current_y + k] != Field.EMPTY:
					print("Non empty 2")
					return false
	
	return true


func place(x: int, y: int, direction: Vector2i, length: int) -> void:
	for i in length:
		board[x + direction.x * i][y + direction.y * i] = Field.SHIP


func remove(x: int, y: int):
	if is_invalid(x, y):
		return
	if board[x][y] == Field.EMPTY:
		return
	
	board[x][y] = Field.EMPTY
	for i in range(-1, 2):
		for j in range(-1, 2):
			remove(x + i, y + j)


func get_length_in_direction(x: int, y: int, direction: Vector2i) -> int:
	var i: int = 1
	while true:
		var current: Vector2i = Vector2i(x + direction.x * i, y + direction.y * i)
		if is_invalid(current.x, current.y):
			return i - 1
		if board[current.x][current.y] == Field.EMPTY:
			return i - 1
		i += 1
	return i - 1


func get_ship_length(x: int, y: int) -> int:
	if board[x][y] == Field.EMPTY:
		return 0
	
	var length: int = 1
	length += get_length_in_direction(x, y, Vector2i.RIGHT)
	length += get_length_in_direction(x, y, Vector2i.LEFT)
	length += get_length_in_direction(x, y, Vector2i.DOWN)
	length += get_length_in_direction(x, y, Vector2i.UP)
	
	return length


func get_ship_count() -> Dictionary:
	var board_copy: Array[Array] = board.duplicate(true)
	var ship_count: Dictionary = {}
	for key in Global.rules["ship_number"]:
		ship_count[key] = 0
	
	for x in 10:
		for y in 10:
			var length: int = get_ship_length(x, y)
			if length:
				remove(x, y)
				ship_count[length] += 1
	board = board_copy
	return ship_count


func parse_hover(x: int, y: int, direction: Vector2i, length: int) -> Array[Array]:
	var result = []
	for i in 10:
		result.append([])
		for j in 10:
			result[i].append(Field.EMPTY)
	
	for i in length:
		var pos: Vector2i = Vector2i(x + direction.x * i, y + direction.y * i)
		if is_invalid(pos.x, pos.y):
			break
		result[pos.x][pos.y] = Field.SHIP
	
	return result
