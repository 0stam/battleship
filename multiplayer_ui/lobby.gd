extends Control

@onready var player_list: VBoxContainer = $VBoxContainer/HBoxContainer/Left/PlayerList/VBoxContainer
@onready var start_button: Button = $VBoxContainer/HBoxContainer/Left/StartGame


func _ready() -> void:
	update_player_list([])
	
	Signals.player_list_updated.connect(update_player_list)


func update_player_list(players: Array) -> void:
	for node in player_list.get_children(): # Remove old nickname labels
		player_list.remove_child(node)
	players.insert(0, Network.nickname)  # Add player name to the array
	for nickname in players: # Add new labels
		var label: Label = Label.new()
		label.text = nickname
		label.clip_text = true
		player_list.add_child(label)
	
	# Change start game button's text
	if multiplayer.is_server():
		if len(players) < 3:
			start_button.text = "Not enough\nplayers (" + str(len(players)) + "/3)"
			start_button.disabled = true
		else:
			start_button.text = "Start game"
			start_button.disabled = false
	else:
		if len(players) > 1:
			start_button.text = "Wait for the host\nto start the game"


func _on_start_game_pressed() -> void:
	Network.rpc(StringName("change_scene"), "res://ship_placement/ship_placement.tscn", false)
