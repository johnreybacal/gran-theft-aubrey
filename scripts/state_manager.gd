extends Node

var is_encountered: bool = false
var encounter_enemy_id: int

var player: Classes.Granny
var enemies: Array[Classes.GrannyNpc] = []
var enemies_defeated: Array[Classes.GrannyNpc] = []

var police_arriving_count: int = 0
var police_timer: Timer

func _ready() -> void:
    police_timer = Timer.new()
    police_timer.one_shot = true
    police_timer.autostart = false
    police_timer.wait_time = 180

    add_child.call_deferred(police_timer)

    EventBus.on_encounter_start.connect(_on_encounter_start)
    EventBus.on_encounter_end.connect(_on_encounter_end)
    EventBus.on_enemy_left.connect(_on_enemy_left)

func _on_encounter_start(instance_id: int):
    is_encountered = true
    encounter_enemy_id = instance_id
    if police_arriving_count > 0:
        police_timer.paused = true

func _on_encounter_end(_instance_id: int, _is_winner: bool):
    is_encountered = false
    encounter_enemy_id = -1
    if police_arriving_count > 0:
        police_timer.paused = false

func _on_enemy_left():
    if police_arriving_count == 0:
        police_timer.start()
    police_arriving_count += 1