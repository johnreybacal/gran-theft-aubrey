extends CharacterBody2D
class_name ExploreEnemy

@export var move_speed: float = 200
@export var arthitis_rate: float = 1.5
var granny: Classes.GrannyNpc
var player: ExplorePlayer

var target_interval: float = .25
var stun_interval: float = 1
var avoid_interval: float = 2
var chase_interval: float = 5

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
    EventBus.on_encounter_end.connect(_on_encounter_end)

    granny = Classes.GrannyNpc.init(get_instance_id(), $GrannyStats, arthitis_rate)
    StateManager.enemies.append(granny)

    # Make sure to not await during _ready.
    _actor_setup.call_deferred()

func _physics_process(delta: float) -> void:
    if StateManager.is_encountered:
        return

    var is_stunned = _check_intervals(delta)

    if navigation_agent.is_navigation_finished() or not granny.can_move() or is_stunned:
        granny.decrease_arthritis(delta)
        return

    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    velocity = global_position.direction_to(next_path_position) * (move_speed * (.75 if granny.is_avoiding else 1.))

    granny.increase_arthritis(delta)
    
    move_and_slide()

func _check_intervals(delta: float):
    if granny.is_stunned:
        stun_interval -= delta
        if stun_interval <= 0:
            granny.is_stunned = false
            stun_interval = 2
            granny.stats.on_stun_end()

        return true

    # Targeting
    target_interval -= delta
    if target_interval <= 0:
        target_interval = .25
        if granny.is_avoiding:
            var direction = player.position.direction_to(position)
            _set_movement_target(position + (direction * 100))
        elif granny.is_chasing:
            _set_movement_target(player.position)

    if granny.can_move():
        if granny.is_avoiding:
            avoid_interval -= delta
            if avoid_interval <= 0:
                granny.is_avoiding = false
                avoid_interval = 2
                granny.stats.on_avoiding_end()
                _set_movement_target(position)

        if granny.is_chasing:
            chase_interval -= delta
            if chase_interval <= 0:
                granny.is_chasing = false
                chase_interval = 5
                granny.stats.on_chasing_end()
                _set_movement_target(position)

    return false


func _actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

func _set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target

func _on_encounter_end(instance_id: int, is_loser: bool):
    if get_instance_id() != instance_id:
        return

    player = instance_from_id(StateManager.player.instance_id)

    target_interval = 0
    stun_interval = 1
    avoid_interval = 2
    chase_interval = 5

    granny.on_encounter_end(is_loser)
