extends CharacterBody2D
class_name ExplorePlayer

@export var move_speed: float = 250
@export var max_arthritis: float = 10
var granny: StateManager.Granny

func _ready() -> void:
    EventBus.on_player_move.connect(_move)
    _init_granny.call_deferred()

func _init_granny():
    granny = StateManager.Granny.init(get_instance_id(), 100)
    StateManager.player = granny
    print(granny)
    print(StateManager.player)


func _physics_process(_delta: float) -> void:
    if StateManager.is_encountered:
        return
    var collision := get_last_slide_collision()
    if collision:
        var collider = collision.get_collider()
        if collider is ExploreEnemy:
            var direction = collider.position.direction_to(position).normalized()
            move_and_collide(direction * 100)
            EventBus.on_encounter_start.emit(collider.get_instance_id())

func _move(direction: Vector2):
    velocity = direction * move_speed
    move_and_slide()