extends Node2D

@onready var hud: HudFight = $CanvasLayer/HudFight
@onready var player_animation: AnimatedSprite2D = $Player
@onready var enemy_animation: AnimatedSprite2D = $Enemy
@onready var move_timer: Timer = $MoveTimer

var is_encounter_over: bool = false
var is_winner: bool = false

func _ready() -> void:
    EventBus.on_encounter_start.connect(_on_encounter_start.unbind(1))
    EventBus.on_encounter_end.connect(_on_encounter_end.unbind(2))
    hide()

    hud.set_max_arthritis(StateManager.player.max_arthritis)
    hud.move_selected.connect(_on_move)

    player_animation.animation_finished.connect(_on_player_animation_finished)
    enemy_animation.animation_finished.connect(_on_enemy_animation_finished)

func _on_visibility_changed() -> void:
    $CanvasLayer.visible = visible

func _on_encounter_start():
    move_timer.wait_time = 1
    is_encounter_over = false
    is_winner = false
    show()
    hud.clear_log()
    hud.update_arthritis(StateManager.player.arthritis)
    
    _play_animation(player_animation, Meta.Moves.Hold)
    _play_animation(enemy_animation, Meta.Moves.Hold)
    $Camera2D.enabled = true

func _on_encounter_end():
    hide()
    $Camera2D.enabled = false


func _on_move(move: Meta.Moves):
    if move_timer.time_left > 0:
        return
    var is_draw = false
    var enemy_move: Meta.Moves = Meta.Moves.values().pick_random()
    _play_animation(player_animation, move)
    _play_animation(enemy_animation, enemy_move)

    hud.append_log("You used " + Meta.get_move_name(move) + " | Enemy used " + Meta.get_move_name(enemy_move))
    
    if move == enemy_move:
        is_draw = true
        hud.append_log("DRAW: Nothing happenned")
    elif move == Meta.Moves.Pull:
        if enemy_move == Meta.Moves.Hold:
            is_winner = true
            hud.append_log("WIN: You yanked the purse")
        elif enemy_move == Meta.Moves.Push:
            hud.append_log("LOST: You fell down and lost the purse")
    elif move == Meta.Moves.Hold:
        if enemy_move == Meta.Moves.Push:
            is_winner = true
            hud.append_log("WIN: Enemy slipped and lost the purse")
        elif enemy_move == Meta.Moves.Pull:
            hud.append_log("LOST: Enemy yanked the purse")
    elif move == Meta.Moves.Push:
        if enemy_move == Meta.Moves.Pull:
            is_winner = true
            hud.append_log("WIN: Enemy fell down and lost the purse")
        elif enemy_move == Meta.Moves.Hold:
            hud.append_log("LOST: You slipped and lost the purse")

    if is_draw:
        StateManager.player.increase_arthritis(1)
        hud.update_arthritis(StateManager.player.arthritis)
        if not StateManager.player.can_move():
            is_encounter_over = true
            move_timer.wait_time = 3
            hud.append_log("LOST: Your knee hurts")
            _play_animation(player_animation, move, true)
            _play_win_animation.call_deferred(enemy_animation)
    else:
        is_encounter_over = true
        move_timer.wait_time = 3
        if is_winner:
            _play_animation(enemy_animation, enemy_move, true)
            _play_win_animation.call_deferred(player_animation)
        else:
            _play_animation(player_animation, move, true)
            _play_win_animation.call_deferred(enemy_animation)

    move_timer.start()

func _play_animation(target: AnimatedSprite2D, move: Meta.Moves, is_loser: bool = false):
    if is_loser:
        if move == Meta.Moves.Pull:
            target.play("pull_fall")
        elif move == Meta.Moves.Push:
            target.play("push_fall")
        else:
            target.play("hold_yoinked")
    else:
        if move == Meta.Moves.Pull:
            target.play("pull")
        elif move == Meta.Moves.Push:
            target.play("push")
        else:
            target.play("hold")

func _play_win_animation(target: AnimatedSprite2D):
    await get_tree().create_timer(1.0).timeout
    target.play("win")

func _on_move_timer_timeout() -> void:
    if is_encounter_over:
        EventBus.on_encounter_end.emit(StateManager.encounter_enemy_id, is_winner)
    else:
        _play_animation(player_animation, Meta.Moves.Hold)
        _play_animation(enemy_animation, Meta.Moves.Hold)

func _on_player_animation_finished():
    if not player_animation.animation.ends_with("_end") and not is_winner:
        player_animation.play(player_animation.animation + "_end")

func _on_enemy_animation_finished():
    if not enemy_animation.animation.ends_with("_end") and is_winner:
        enemy_animation.play(enemy_animation.animation + "_end")
