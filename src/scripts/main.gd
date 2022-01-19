extends Node

const seal_history = preload("res://src/scene/Kekai.tscn")

func _ready():
	pass # Replace with function body.

func _on_Kekai_pressed(seal_amount):
	Global.STAGE_PARAM = [seal_amount]
	get_tree().change_scene("res://src/scene/Kekai.tscn")
