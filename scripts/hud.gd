extends Control
class_name Hud

@onready var stats: GrannyStats = $VBoxContainer/GrannyStats
@onready var stars: HBoxContainer = $VBoxContainer/Stars
@onready var police_timer_label: Label = $VBoxContainer/PoliceTimerLabel

var hud_star_scene = preload("res://scenes/hud_star.tscn")

func _ready() -> void:
    EventBus.on_enemy_left.connect(_on_enemy_left)

func _process(_delta: float) -> void:
    if StateManager.police_arriving_count > 0:
        var m = "0" + str(int(StateManager.police_timer.time_left) / 60)
        var s = "0" + str(int(StateManager.police_timer.time_left) % 60)
        police_timer_label.text = "Police arrives in: " + m.right(2) + ":" + s.right(2)


func _on_enemy_left():
    var star = hud_star_scene.instantiate()
    stars.add_child.call_deferred(star)