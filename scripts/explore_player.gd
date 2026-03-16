extends CharacterBody2D
class_name ExplorePlayer

@export var move_speed: float = 250
@export var arthitis_rate: float = 1
var granny: Classes.Granny

func _ready() -> void:
    EventBus.on_player_move.connect(_move)
    granny = Classes.Granny.init(get_instance_id(), $GrannyStats, arthitis_rate)
    StateManager.player = granny


func _physics_process(delta: float) -> void:
    if StateManager.is_encountered:
        return

    if granny:
        if velocity != Vector2.ZERO and granny.can_move():
            granny.increase_arthritis(delta)
        else:
            granny.decrease_arthritis(delta)
        
    var collision := get_last_slide_collision()
    if collision:
        var collider = collision.get_collider()
        if collider is ExploreEnemy:
            var direction = collider.position.direction_to(position).normalized()
            move_and_collide(direction * 25)
            EventBus.on_encounter_start.emit(collider.get_instance_id())

func _move(direction: Vector2):
    if granny.can_move():
        velocity = direction * move_speed
        move_and_slide()
