extends StaticBody2D
class_name Interactable

@onready var label: Label = $Label

@export var label_text: String = "(E) Interact"

var is_interactable: bool = true
var is_focus: bool = false
var focus_interval: float = 0

func _ready() -> void:
    label.text = label_text
    label.hide()

func on_focus_gained():
    if not is_interactable:
        return
    if not is_focus:
        focus_interval = get_physics_process_delta_time() * 3
    else:
        focus_interval += get_physics_process_delta_time()
    is_focus = true
    label.show()

func on_focus_lost():
    is_focus = false
    label.hide()

func _physics_process(delta: float) -> void:
    if is_focus:
        if not is_interactable:
            on_focus_lost()
            return
        focus_interval -= delta
        if focus_interval <= 0:
            on_focus_lost()

func _input(event: InputEvent):
    if event.is_action_pressed("interact") and is_focus:
        EventBus.on_interact.emit(get_parent().get_instance_id())
