extends Control
class_name Hud

@onready var stats: GrannyStats = $VBoxContainer/GrannyStats
@onready var purse_stolen_label: Label = $VBoxContainer/PurseStolenLabel
@onready var stars: HBoxContainer = $VBoxContainer/Stars
@onready var police_timer_label: Label = $VBoxContainer/PoliceTimerLabel

var hud_star_scene = preload("res://scenes/hud_star.tscn")

func _ready() -> void:
    EventBus.on_enemy_left.connect(_on_enemy_left)
    EventBus.on_purse_stolen_updated.connect(_on_purse_stolen_updated)

func _process(_delta: float) -> void:
    if StateManager.police_arriving_count > 0:
        var m = "0" + str(int(StateManager.police_timer.time_left) / 60)
        var s = "0" + str(int(StateManager.police_timer.time_left) % 60)
        police_timer_label.text = "Police arrives in: " + m.right(2) + ":" + s.right(2)


func _on_enemy_left():
    var star = hud_star_scene.instantiate()
    stars.add_child.call_deferred(star)

func _on_purse_stolen_updated():
    purse_stolen_label.text = "Purse Stolen: " + str(len(StateManager.enemies_defeated))