extends Node2D

@onready var hud: Hud = $CanvasLayer/Hud
@onready var player: ExplorePlayer = $ExplorePlayer
@onready var camera: Camera2D = $Camera2D

var enemy_scene = preload("res://scenes/explore_enemy.tscn")

var is_police_spotlight: bool = false
var police_entry_x: float

func _ready() -> void:
    var fight_scene = preload("res://scenes/game_fight.tscn").instantiate()
    var end_scene = preload("res://scenes/end.tscn").instantiate()
    get_tree().root.add_child.call_deferred(fight_scene)
    get_tree().root.add_child.call_deferred(end_scene)

    EventBus.on_encounter_start.connect(_on_encounter_start.call_deferred.unbind(1))
    EventBus.on_encounter_end.connect(_on_encounter_end.call_deferred.unbind(2))
    EventBus.on_police_arrival.connect(_on_police_arrival)
    EventBus.on_escape.connect(_on_escape)
    
    show()
    _setup_player_hud.call_deferred()

    StateManager.update_interactables()

func _process(_delta: float) -> void:
    if not is_police_spotlight:
        camera.position = player.position
    else:
        camera.position = Vector2(police_entry_x, 0)

func _on_encounter_start():
    hide()
    camera.enabled = false

func _on_encounter_end():
    if StateManager.is_end:
       queue_free()
    else:
        show()
        camera.enabled = true

func _on_escape():
    queue_free()

func _on_visibility_changed() -> void:
    $CanvasLayer.visible = visible

func _setup_player_hud():
    player.granny.stats = hud.stats
    hud.stats.set_max_arthritis(player.granny.max_arthritis)
    hud.stats.update_arthritis(player.granny.arthritis)

func _on_police_arrival():
    var x_modifier: int = 1 if player.position.x > 0 else -1
    var y_modifier: int = 0
    police_entry_x = 2048 * x_modifier
    var enemies: Array[ExploreEnemy] = []
    for i in range(StateManager.police_arriving_count):
        y_modifier += 100
        var enemy: ExploreEnemy = enemy_scene.instantiate()
        enemy.is_police = true
        enemy.player = player
        enemy.arthitis_rate = 0.95
        enemy.global_position = Vector2(randf_range(2070, 2400) * x_modifier, y_modifier)

        enemies.append(enemy)

    var y_start = len(enemies) * -25

    for enemy in enemies:
        enemy.position.y += y_start
        add_child.call_deferred(enemy)

    $PoliceSpotlightTimer.start()
    is_police_spotlight = true

    # 1, 2, 4
    # 1, 2, 8
    player.collision_mask = 11
    player.can_escape = true


func _on_police_spotlight_timer_timeout() -> void:
    is_police_spotlight = false
