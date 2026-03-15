extends Node

signal on_player_move(direction: Vector2)
signal on_encounter_start(instance_id: int)
signal on_encounter_end(instance_id: int, is_purse_stolen: bool)


func _physics_process(_delta: float) -> void:
    if not StateManager.is_encountered:
        var move_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        on_player_move.emit(move_vector)
