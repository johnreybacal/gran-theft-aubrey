extends Node2D

@onready var hud: Hud = $CanvasLayer/Hud
@onready var player: ExplorePlayer = $ExplorePlayer

func _ready() -> void:
    var fight_scene = preload("res://scenes/game_fight.tscn").instantiate()
    get_tree().root.add_child.call_deferred(fight_scene)
    EventBus.on_encounter_start.connect(_on_encounter_start.unbind(1))
    EventBus.on_encounter_end.connect(_on_encounter_end.unbind(2))
    show()
    _setup_player_hud.call_deferred()

func _on_encounter_start():
    hide()
    $ExplorePlayer/Camera2D.enabled = false

func _on_encounter_end():
    show()
    $ExplorePlayer/Camera2D.enabled = true

func _on_visibility_changed() -> void:
    $CanvasLayer.visible = visible

func _setup_player_hud():
    player.granny.stats = hud.stats
    hud.stats.set_max_arthritis(player.granny.max_arthritis)
    hud.stats.update_arthritis(player.granny.arthritis)
