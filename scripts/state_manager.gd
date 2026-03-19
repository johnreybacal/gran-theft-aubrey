extends Node

var is_encountered: bool = false
var encounter_enemy_id: int

var player: Classes.Granny
var enemies: Array[Classes.GrannyNpc] = []
var enemies_defeated: Array[Classes.GrannyNpc] = []

var police_arriving_count: int = 0
var police_timer: Timer
var is_busted: bool = false
var is_end: bool = false

var interactable_id: int
var interactables = []

var explore_sfx_bus: int = AudioServer.get_bus_index("ExploreSfx")

func _ready() -> void:
    police_timer = Timer.new()
    police_timer.one_shot = true
    police_timer.autostart = false
    police_timer.wait_time = 180
    police_timer.wait_time = 30

    add_child.call_deferred(police_timer)

    EventBus.on_encounter_start.connect(_on_encounter_start)
    EventBus.on_encounter_end.connect(_on_encounter_end)
    EventBus.on_enemy_left.connect(_on_enemy_left)
    EventBus.on_interact.connect(_on_interact)
    EventBus.on_escape.connect(_on_escape)
    police_timer.timeout.connect(EventBus.on_police_arrival.emit)

    update_interactables()

func _on_encounter_start(instance_id: int):
    is_encountered = true
    encounter_enemy_id = instance_id
    if police_arriving_count > 0:
        police_timer.paused = true

    AudioServer.set_bus_mute(explore_sfx_bus, true)

func _on_encounter_end(instance_id: int, is_winner: bool):
    is_encountered = false
    encounter_enemy_id = -1
    if police_arriving_count > 0:
        police_timer.paused = false

    var enemy = instance_from_id(instance_id)
    if enemy is ExploreEnemy:
        if enemy.is_police and not is_winner:
            is_end = true
            is_busted = true

    AudioServer.set_bus_mute(explore_sfx_bus, false)

func _on_escape():
    is_end = true

func _on_enemy_left():
    if police_arriving_count == 0:
        police_timer.start()
    police_arriving_count += 1

func _on_interact(instance_id: int):
    var node: Node2D = instance_from_id(instance_id)
    if node is ExploreEnemy:
        EventBus.on_encounter_start.emit(instance_id)

func update_interactables():
    interactables = get_tree().get_nodes_in_group("Interactable")
