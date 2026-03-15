extends Node2D
class_name GrannyStats

const STUNNED = "Stunned."
const KNEES_HURT = "Knees Hurt."


@onready var arthritis_bar: TextureProgressBar = $ArthritisBar
@onready var state_label: Label = $StateLabel

func _ready() -> void:
    state_label.text = ""

func set_max_arthritis(max_value: float):
    arthritis_bar.max_value = max_value

func update_arthritis(value: float):
    arthritis_bar.value = value

func on_stunned():
    add_label(STUNNED)

func on_stun_end():
    remove_label(STUNNED)

func on_knees_hurt():
    add_label(KNEES_HURT)

func on_knees_hurt_end():
    remove_label(KNEES_HURT)

func add_label(text: String):
    if not state_label.text.contains(text):
        state_label.text += " " + text
        state_label.text = state_label.text.strip_edges()

func remove_label(text: String):
    if state_label.text.contains(text):
        state_label.text = state_label.text.replace(text, "")
        state_label.text = state_label.text.strip_edges()
