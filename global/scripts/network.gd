extends Node

const DEFAULT_PORT: int = 28960
const MAX_CLIENTS: int = 2

var peer: ENetMultiplayerPeer = null

var nickname: String = "ktostam"
var players: Dictionary = {}
var chat: Array = []

signal player_list_changed

func _ready() -> void:
	print("Program started")
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _player_connected(id):
	print("Player " + str(id) + " has connected")
	rpc_id(id, StringName("register_player"), nickname)
	if multiplayer.is_server():
		rpc_id(id, StringName("set_chat_history"), chat)

func _player_disconnected(id):
	if id in players:
		players.erase(id)
		Signals.player_list_updated.emit(players.values())
	print("Player " + str(id) + " has disconnected")

func _connected_to_server():
	print("Connected to server")

func _connection_failed():
	print("Server connection failed")
	change_scene("res://multiplayer_ui/connection_screen.tscn")

func _server_disconnected():
	print("Server disconnected")
	change_scene("res://multiplayer_ui/connection_screen.tscn")

func create_server(new_name: String):
	nickname = new_name
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)

func join_server(ip: String, new_name: String):
	nickname = new_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)

@rpc(any_peer)
func register_player(player_name: String):
	players[multiplayer.get_remote_sender_id()] = player_name
	Signals.player_list_updated.emit(players.values())
	print(player_name)

@rpc
func set_chat_history(chat_history: Array):
	chat = chat_history
	Signals.chat_history_updated.emit(chat.duplicate(true))

@rpc(call_local)
func change_scene(scene: String):
	get_tree().change_scene(scene)
