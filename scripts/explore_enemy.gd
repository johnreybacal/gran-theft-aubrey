extends CharacterBody2D
class_name ExploreEnemy

@export var move_speed: float = 200
@export var max_arthritis: float = 2
var granny: StateManager.GrannyNpc
var player: ExplorePlayer

var target_interval: float = .25
var stun_interval: float = 1
var avoid_interval: float = 2
var chase_interval: float = 5

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
    EventBus.on_encounter_end.connect(_on_encounter_end)

    granny = StateManager.GrannyNpc.init(get_instance_id(), max_arthritis)
    StateManager.enemies.append(granny)

    # Make sure to not await during _ready.
    _actor_setup.call_deferred()

    
func _process(delta: float) -> void:
    if granny.is_stunned:
        stun_interval -= delta
        if stun_interval <= 0:
            granny.is_stunned = false
            stun_interval = 2

        return

    if player and granny.is_moving() and granny.can_move():
        target_interval -= delta

        # Targeting
        if target_interval <= 0:
            target_interval = .25
            if granny.is_avoiding:
                var direction = player.position.direction_to(position)
                _set_movement_target(position + (direction * 100))
            elif granny.is_chasing:
                _set_movement_target(player.position)

        if granny.is_avoiding:
            avoid_interval -= delta
            if avoid_interval <= 0:
                granny.is_avoiding = false
                avoid_interval = 2

        if granny.is_chasing:
            chase_interval -= delta
            if chase_interval <= 0:
                granny.is_chasing = false
                chase_interval = 5


func _physics_process(delta: float) -> void:
    if navigation_agent.is_navigation_finished() or StateManager.is_encountered:
        granny.decrease_arthritis(delta)
        return

    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    velocity = global_position.direction_to(next_path_position) * (move_speed * (.75 if granny.is_avoiding else 1.))

    granny.increase_arthritis(delta)
    
    move_and_slide()

    var collision := get_last_slide_collision()
    if collision:
        var collider = collision.get_collider()
        if collider is ExplorePlayer:
            var direction = collider.position.direction_to(position).normalized()
            move_and_collide(direction * 25)
            EventBus.on_encounter_start.emit(get_instance_id())

func _actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

func _set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target

func _on_encounter_end(instance_id: int, is_loser: bool):
    if get_instance_id() != instance_id:
        return

    player = instance_from_id(StateManager.player.instance_id)

    target_interval = .25
    stun_interval = 1
    avoid_interval = 2
    chase_interval = 5

    if is_loser:
        granny.is_avoiding = false
        granny.is_chasing = true
        granny.is_stunned = true
        StateManager.enemies_defeated.append(granny)
    else:
        granny.is_chasing = false
        granny.is_avoiding = true
        if granny in StateManager.enemies_defeated:
            var index: int = StateManager.enemies_defeated.find(granny)
            if index != -1:
                StateManager.enemies_defeated.remove_at(index)
