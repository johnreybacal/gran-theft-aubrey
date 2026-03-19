extends Node2D
class_name GrannySfx

@onready var footstep: AudioStreamPlayer2D = $Footstep
@onready var knees_hurt: AudioStreamPlayer2D = $KneesHurt
@onready var leaving: AudioStreamPlayer2D = $Leaving
var is_leaving: bool = false


func play_footstep():
    if not footstep.playing:
        footstep.pitch_scale = randf_range(.95, 1.05)
        footstep.volume_db = randf_range(4.5, 5.5)
        footstep.play()

func play_knees_hurt():
    if not knees_hurt.playing:
        if is_leaving:
            leaving.volume_db = -100
        knees_hurt.pitch_scale = randf_range(.9, 1.1)
        knees_hurt.play()

func play_leaving():
    if not is_leaving:
        is_leaving = true
        leaving.play()

func on_recovery() -> void:
    if is_leaving:
        leaving.volume_db = 0
