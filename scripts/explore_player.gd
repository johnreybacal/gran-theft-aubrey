extends CharacterBody2D
class_name ExplorePlayer

var move_speed: float = 250


func _ready() -> void:
    EventBus.on_player_move.connect(_move)

func _physics_process(_delta: float) -> void:
    if EventBus.is_encountered:
        return
    var collision := get_last_slide_collision()
    if collision:
        var collider = collision.get_collider()
        if collider is ExploreEnemy:
            var direction = collider.position.direction_to(position).normalized()
            move_and_collide(direction * 100)
            EventBus.toggle_encounter.emit(true)

func _move(direction: Vector2):
    velocity = direction * move_speed
    move_and_slide()