extends Node2D
class_name GrannySfx

@onready var footstep: AudioStreamPlayer2D = $Footstep

func play_footstep():
    if not footstep.playing:
        footstep.pitch_scale = randf_range(.95, 1.05)
        footstep.volume_db = randf_range(4.5, 5.5)
        footstep.play()

func stop_footstep():
    footstep.stop()