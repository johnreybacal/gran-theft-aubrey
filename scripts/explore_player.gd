extends CharacterBody2D
class_name ExplorePlayer

@onready var interact_ray_cast: RayCast2D = $InteractRayCast

@export var move_speed: float = 250
var move_vector: Vector2
@export var arthitis_rate: float = 1
var granny: Classes.Granny

var interact_ray_cast_direction_interval: float = .1
var can_escape: bool = false

func _ready() -> void:
    granny = Classes.Granny.init(get_instance_id(), $GrannyStats, $AnimatedSprite2D, $GrannySfx, arthitis_rate)
    StateManager.player = granny


func _physics_process(delta: float) -> void:
    _handle_animation_and_sound()
    if StateManager.is_encountered:
        return

    move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if granny.can_move():
        velocity = move_vector * move_speed
    else:
        velocity = Vector2.ZERO

    move_and_slide()

    if velocity != Vector2.ZERO and granny.can_move():
        granny.increase_arthritis(delta)
    else:
        granny.decrease_arthritis(delta)

    _check_interact_ray_cast.call_deferred(delta)

    if can_escape:
        for i in get_slide_collision_count():
            var collision = get_slide_collision(i)
            if collision:
                var collider: Node2D = collision.get_collider()
                if collider.is_in_group("EscapeArea"):
                    EventBus.on_escape.emit()

    
func _handle_animation_and_sound():
    if velocity != Vector2.ZERO:
        granny.play_walk(move_vector.x < 0)
    elif granny.can_move():
        granny.play_idle()
    else:
        granny.play_knees_hurt()


func _check_interact_ray_cast(delta: float):
    if not granny.can_move():
        return

    interact_ray_cast_direction_interval -= delta
    if interact_ray_cast_direction_interval <= 0:
        interact_ray_cast_direction_interval = .1
        if len(StateManager.interactables) > 0:
            var closest = null
            var distance = INF
            for interactable in StateManager.interactables:
                if not is_instance_valid(interactable):
                    continue
                var d = interact_ray_cast.global_position.distance_squared_to(interactable.global_position)
                if d < distance:
                    closest = interactable
                    distance = d
            var direction = interact_ray_cast.global_position.direction_to(closest.global_position)
            interact_ray_cast.target_position = direction * 100


    if interact_ray_cast.is_colliding():
        var collider = interact_ray_cast.get_collider()
        if collider is Interactable:
            collider.on_focus_gained()