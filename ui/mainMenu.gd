extends Control
## Main menu class.
class_name MainMenu
## Button for starting game.
@onready var btn: Button = $MarginContainer/VBoxContainer/Button

## Init constructor.
func _ready() -> void:
	btn.pressed.connect(_on_start_game)

## Game required to start.
func _on_start_game() -> void:
	get_tree().change_scene_to_file("res://levels/skyblock.tscn")
