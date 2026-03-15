extends Node2D

func _ready() -> void:
    var fight_scene = preload("res://scenes/game_fight.tscn").instantiate()
    get_tree().root.add_child.call_deferred(fight_scene)
    EventBus.on_encounter_start.connect(hide.unbind(1))
    EventBus.on_encounter_end.connect(show.unbind(2))
    show()
