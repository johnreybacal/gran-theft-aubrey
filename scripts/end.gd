extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    hide()
    camera.enabled = false
    EventBus.on_encounter_end.connect(_show_end.call_deferred.unbind(2))
    EventBus.on_escape.connect(_show_end.call_deferred)


func _show_end():
    if StateManager.is_end:
        show()
        camera.enabled = true
        if StateManager.is_busted:
            label.text = "GRANY OTTO FINALLY CAUGHT!"
            $SFX/Lose.play()
            $AnimatedSprite2D.play("lose")
        else:
            label.text = "GRANNY OTTO STRIKES AGAIN!"
            $SFX/Win.play()
            $AnimatedSprite2D.play("win")


func _on_restart_button_pressed() -> void:
    EventBus.on_encounter_end.disconnect(_show_end.call_deferred.unbind(2))
    EventBus.on_escape.disconnect(_show_end.call_deferred)
    get_tree().change_scene_to_file("res://scenes/start.tscn")
