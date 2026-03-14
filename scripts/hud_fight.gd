extends Control
class_name HudFight

@onready var fight_log: Label = $FightLog

signal move_selected(move: Meta.Moves)

func append_log(value: String):
    fight_log.text += value + "\n"
    print(value)

func clear_log():
    fight_log.text = ""

func _on_push_button_pressed() -> void:
    move_selected.emit(Meta.Moves.Push)

func _on_hold_button_pressed() -> void:
    move_selected.emit(Meta.Moves.Hold)

func _on_pull_button_pressed() -> void:
    move_selected.emit(Meta.Moves.Pull)
