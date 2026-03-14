extends Node2D

func _ready() -> void:
    var fight_scene = preload("res://scenes/game_fight.tscn").instantiate()
    get_tree().root.add_child.call_deferred(fight_scene)
    EventBus.toggle_encounter.connect(_on_encounter)
    show()

func _on_encounter(is_encountered: bool):
    if is_encountered:
        hide()
    else:
        show()
