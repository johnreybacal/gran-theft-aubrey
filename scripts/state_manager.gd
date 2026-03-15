extends Node

var is_encountered: bool = false
var encounter_enemy_id: int

var player: Classes.Granny
var enemies: Array[Classes.GrannyNpc] = []
var enemies_defeated: Array[Classes.GrannyNpc] = []

func _ready() -> void:
    EventBus.on_encounter_start.connect(_on_encounter_start)
    EventBus.on_encounter_end.connect(_on_encounter_end)

func _on_encounter_start(instance_id: int):
    is_encountered = true
    encounter_enemy_id = instance_id

func _on_encounter_end(_instance_id: int, _is_winner: bool):
    is_encountered = false
    encounter_enemy_id = -1
