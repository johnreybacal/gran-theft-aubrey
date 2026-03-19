extends Node2D

@onready var camera: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    hide()
    camera.enabled = false
    EventBus.on_encounter_end.connect(_on_encounter_end.call_deferred.unbind(2))


func _on_encounter_end():
    if StateManager.is_busted:
        show()
        camera.enabled = true
