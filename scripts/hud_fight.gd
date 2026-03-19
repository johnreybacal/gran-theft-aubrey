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

func disable_buttons():
    $VBoxContainer/HBoxContainer/PullButton.disabled = true
    $VBoxContainer/HBoxContainer/HoldButton.disabled = true
    $VBoxContainer/HBoxContainer/PushButton.disabled = true
    $VBoxContainer/HBoxContainer/PullButton.visible = false
    $VBoxContainer/HBoxContainer/HoldButton.visible = false
    $VBoxContainer/HBoxContainer/PushButton.visible = false

func enable_buttons():
    $VBoxContainer/HBoxContainer/PullButton.disabled = false
    $VBoxContainer/HBoxContainer/HoldButton.disabled = false
    $VBoxContainer/HBoxContainer/PushButton.disabled = false
    $VBoxContainer/HBoxContainer/PullButton.visible = true
    $VBoxContainer/HBoxContainer/HoldButton.visible = true
    $VBoxContainer/HBoxContainer/PushButton.visible = true
