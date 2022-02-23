extends Control

@onready var name_edit: LineEdit = $Panel/VBoxContainer/Name/NameEdit
@onready var ip_edit: LineEdit = $Panel/VBoxContainer/IP/IPEdit


func _on_create_server_pressed() -> void:
	if not name_edit.text.is_empty():
		Network.create_server(name_edit.text)
		#get_tree().change_scene("")


func _on_join_server_pressed() -> void:
	if not (name_edit.text.is_empty() or ip_edit.text.is_empty()):
		Network.join_server(ip_edit.text, name_edit.text)
		#get_tree().change_scene("")
