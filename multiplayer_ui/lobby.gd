extends Control

@onready var player_list: VBoxContainer = $VBoxContainer/HBoxContainer/Left/PlayerList/VBoxContainer
@onready var start_button: Button = $VBoxContainer/HBoxContainer/Left/StartGame


func _ready() -> void:
	update_player_list([])
	
	Signals.player_list_updated.connect(update_player_list)


func update_player_list(players: Array) -> void:
	for node in player_list.get_children():
		player_list.remove_child(node)
	players.insert(0, Network.nickname)
	for nickname in players:
		var label: Label = Label.new()
		label.text = nickname
		label.clip_text = true
		player_list.add_child(label)
	
	if multiplayer.is_server():
		if len(Network.players) < 2:
			start_button.text = "Not enough\nplayers (" + str(len(Network.players) + 1) + "/3)"
			start_button.disabled = true
		else:
			start_button.text = "Start game"
			start_button.disabled = false


func _on_start_game_pressed() -> void:
	Network.rpc(StringName("change_scene"), "res://ship_placement/ship_placement.tscn")
