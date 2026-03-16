extends CharacterBody2D
class_name ExplorePlayer

@export var move_speed: float = 250
@export var arthitis_rate: float = 1
var granny: Classes.Granny

func _ready() -> void:
    granny = Classes.Granny.init(get_instance_id(), $GrannyStats, arthitis_rate)
    StateManager.player = granny


func _physics_process(delta: float) -> void:
    if StateManager.is_encountered:
        return

    var move_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if granny.can_move():
        velocity = move_vector * move_speed
    else:
        velocity = Vector2.ZERO

    move_and_slide()

    if velocity != Vector2.ZERO and granny.can_move():
        granny.increase_arthritis(delta)
    else:
        granny.decrease_arthritis(delta)
        
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        if collision:
            var collider = collision.get_collider()
            if collider is ExploreEnemy:
                if not collider.granny.can_encounter():
                    return
                var direction = collider.position.direction_to(position).normalized()
                move_and_collide(direction * 50)
                EventBus.on_encounter_start.emit(collider.get_instance_id())
