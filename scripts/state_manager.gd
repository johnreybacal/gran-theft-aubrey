extends Node

var is_encountered: bool = false
var encounter_enemy_id: int

class Granny:
    var instance_id: int
    var arthritis: float
    var max_arthritis: float

    func init_values(p_instance_id: int, p_max_arthritis: float):
        instance_id = p_instance_id
        max_arthritis = p_max_arthritis
        arthritis = 0

    static func init(p_instance_id: int, p_max_arthritis: float):
        var instance = Granny.new()
        instance.init_values(p_instance_id, p_max_arthritis)
        return instance

class GrannyNpc extends Granny:
    var is_chasing: bool = false
    var is_avoiding: bool = false
    var is_stunned: bool = false
    
    static func init(p_instance_id: int, p_max_arthritis: float):
        var instance = GrannyNpc.new()
        instance.init_values(p_instance_id, p_max_arthritis)
        return instance

    func is_moving():
        return is_chasing or is_avoiding

var player: Granny
var enemies: Array[GrannyNpc] = []
var enemies_defeated: Array[GrannyNpc] = []

func _ready() -> void:
    EventBus.on_encounter_start.connect(_on_encounter_start)
    EventBus.on_encounter_end.connect(_on_encounter_end)

func _on_encounter_start(instance_id: int):
    is_encountered = true
    encounter_enemy_id = instance_id

func _on_encounter_end(_instance_id: int, _is_winner: bool):
    is_encountered = false
    encounter_enemy_id = -1