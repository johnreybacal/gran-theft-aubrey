extends Node2D

func _ready() -> void:
    var fight_scene = preload("res://scenes/game_fight.tscn").instantiate()
    get_tree().root.add_child.call_deferred(fight_scene)
    EventBus.on_encounter_start.connect(_on_encounter_start.unbind(1))
    EventBus.on_encounter_end.connect(_on_encounter_end.unbind(2))
    show()

func _on_encounter_start():
    hide()
    $ExplorePlayer/Camera2D.enabled = false

func _on_encounter_end():
    show()
    $ExplorePlayer/Camera2D.enabled = true
