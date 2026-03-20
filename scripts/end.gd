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
            label.text = "GRANNY OTTO FINALLY CAUGHT!"
            $SFX/Lose.play()
            $AnimatedSprite2D.play("lose")
        else:
            label.text = "GRANNY OTTO STRIKES AGAIN!"
            $SFX/Win.play()
            $AnimatedSprite2D.play("win")
        label.text += "\nNOTORIETY: " + str(StateManager.police_arriving_count)
        label.text += "\nPURSE STOLEN: " + str(len(StateManager.enemies_defeated))


func _on_restart_button_pressed() -> void:
    $RestartButton.disabled = true
    $RestartButton.visible = false
    
    var start_scene = preload("res://scenes/start.tscn").instantiate()

    get_tree().root.add_child(start_scene)
    get_tree().current_scene = start_scene

    StateManager.bgm.stop()

    if has_node("/root/GameExplore"):
        get_node("/root/GameExplore").queue_free()
    if has_node("/root/GameFight"):
        get_node("/root/GameFight").queue_free()
    if has_node("/root/End"):
        get_node("/root/End").queue_free()
