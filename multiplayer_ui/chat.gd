extends VBoxContainer

@onready var message_scene: PackedScene = preload("res://multiplayer_ui/message.tscn")

@onready var messages_scroll: ScrollContainer = $MessagesScroll
@onready var scroll_bar: VScrollBar = messages_scroll.get_v_scroll_bar()
@onready var messages: VBoxContainer = $MessagesScroll/Messages
@onready var edit: LineEdit = $MessageSender/Edit


func _ready() -> void:
	Signals.chat_history_updated.connect(parse_chat)


@rpc(any_peer, call_local)
func add_message(nickname: String, content: String) -> void:
	var message: Panel = message_scene.instantiate()
	message.nickname = nickname
	message.content = content
	messages.add_child(message)
	
	Network.chat.append([nickname, content])
	
	await get_tree().process_frame
	messages_scroll.scroll_vertical = scroll_bar.max_value
	
	


func parse_chat(chat_history: Array) -> void:
	for message in chat_history:
		add_message(message[0], message[1])


func _on_send_pressed() -> void:
	if not edit.text.is_empty():
		rpc(StringName("add_message"), Network.nickname, edit.text)
		edit.text = ""
