extends Node

var is_encountered: bool = false

signal on_player_move(direction: Vector2)
signal toggle_encounter(value: bool)

func _ready() -> void:
    toggle_encounter.connect(_toggle_encounter)

func _physics_process(_delta: float) -> void:
    var move_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    on_player_move.emit(move_vector)

func _toggle_encounter(value: bool):
    is_encountered = value