extends CharacterBody2D
class_name ExploreEnemy

@export var move_speed: float = 225
@export var arthitis_rate: float = 1.25
var granny: Classes.GrannyNpc
var player: ExplorePlayer

var target_interval: float = .25
var stun_interval: float = 1
var avoid_interval: float = 2
var chase_interval: float = 5

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
    EventBus.on_encounter_end.connect(_on_encounter_end)

    granny = Classes.GrannyNpc.init(get_instance_id(), $GrannyStats, $AnimatedSprite2D, arthitis_rate)
    StateManager.enemies.append(granny)

    # Make sure to not await during _ready.
    _actor_setup.call_deferred()

func _physics_process(delta: float) -> void:
    _handle_animation()
    if StateManager.is_encountered:
        return

    _check_intervals(delta)


    var next_path_position: Vector2 = navigation_agent.get_next_path_position()
    var new_velocity: Vector2 = global_position.direction_to(next_path_position) * move_speed * (.75 if granny.is_avoiding else 1.)

    if navigation_agent.avoidance_enabled:
        navigation_agent.set_velocity(new_velocity)
    else:
        _on_navigation_agent_2d_velocity_computed(new_velocity)

    
    if granny.is_leaving and abs(position.x) > 2100:
        EventBus.on_enemy_left.emit()
        free.call_deferred()
        StateManager.update_interactables.call_deferred()

    move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    var delta = get_physics_process_delta_time()
    if granny.can_move() and granny.is_on_the_move():
        # global_position = global_position.move_toward(global_position + safe_velocity, delta * (.75 if granny.is_avoiding else 1.))
        velocity = safe_velocity
        granny.increase_arthritis(delta)
    else:
        granny.decrease_arthritis(delta)
        velocity = Vector2.ZERO


func _handle_animation():
    if granny.is_on_the_move():
        if granny.can_move():
            granny.play_walk(velocity.x < 0)
        else:
            granny.play_knees_hurt()
    else:
        granny.play_idle()

func _check_intervals(delta: float):
    if granny.is_stunned:
        stun_interval -= delta
        if stun_interval <= 0:
            granny.is_stunned = false
            stun_interval = 2
            granny.stats.on_stun_end()
        return


    # Targeting
    if granny.is_on_the_move():
        target_interval -= delta
        if target_interval <= 0:
            target_interval = .25
            if granny.is_avoiding:
                var direction = player.position.direction_to(position)
                var target_position = position + (direction * 300)
                if abs(target_position.x) > 2048:
                    target_position.y += 300 * (1 if position.y < 0 else -1)
                if abs(target_position.y) > 1024:
                    target_position.x += 300 * (1 if position.x < 0 else -1)
                _set_movement_target(target_position)
            elif granny.is_chasing:
                _set_movement_target(player.position)
            elif granny.is_leaving:
                _leave()
            

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
                # Ignore Bounds
                _leave()

        
func _leave():
    interactable.is_interactable = false
    collision_mask = 1
    navigation_agent.avoidance_mask = 3
    granny.is_leaving = true
    granny.arthritis_rate = .75
    granny.stats.on_leaving()
    _set_movement_target(Vector2(2500 * (1 if position.x >= 0 else -1), randf_range(position.y - 100, position.y + 100)))

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

    if is_loser:
        # Ignore player avoidance when chasing
        navigation_agent.avoidance_mask = 2
        interactable.is_interactable = false
    else:
        navigation_agent.avoidance_mask = 3
        interactable.is_interactable = true

    
    granny.on_encounter_end(is_loser)
