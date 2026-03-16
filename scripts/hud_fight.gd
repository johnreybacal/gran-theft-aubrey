extends Control
class_name HudFight

@onready var fight_log: Label = $FightLog
@onready var arthritis_bar: TextureProgressBar = $VBoxContainer/ArthritisBar

signal move_selected(move: Meta.Moves)

func append_log(value: String):
    fight_log.text += value + "\n"
    print(value)

func clear_log():
    fight_log.text = ""

func set_max_arthritis(max_value: float):
    arthritis_bar.max_value = max_value

func update_arthritis(value: float):
    arthritis_bar.value = value

func _on_push_button_pressed() -> void:
    move_selected.emit(Meta.Moves.Push)

func _on_hold_button_pressed() -> void:
    move_selected.emit(Meta.Moves.Hold)

func _on_pull_button_pressed() -> void:
    move_selected.emit(Meta.Moves.Pull)
