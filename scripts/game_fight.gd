extends Node2D

@onready var hud: HudFight = $CanvasLayer/HudFight
@onready var player: AnimatedSprite2D = $Player
@onready var purse: AnimatedSprite2D = $Purse
@onready var enemy: AnimatedSprite2D = $Enemy
@onready var move_timer: Timer = $MoveTimer

var is_encounter_over: bool = false
var is_winner: bool = false

func _ready() -> void:
    EventBus.on_encounter_start.connect(_on_encounter_start.call_deferred.unbind(1))
    EventBus.on_encounter_end.connect(_on_encounter_end.call_deferred.unbind(2))
    hide()

    hud.set_max_arthritis(StateManager.player.max_arthritis)
    hud.move_selected.connect(_on_move)

    player.animation_finished.connect(_on_player_animation_finished)
    enemy.animation_finished.connect(_on_enemy_animation_finished)

func _on_visibility_changed() -> void:
    $CanvasLayer.visible = visible

func _on_encounter_start():
    hud.enable_buttons()
    move_timer.wait_time = 1
    is_encounter_over = false
    is_winner = false
    show()
    hud.clear_log()
    hud.update_arthritis(StateManager.player.arthritis)
    
    _play_animation(player, Meta.Moves.Hold)
    _play_animation(enemy, Meta.Moves.Hold)
    $Camera2D.enabled = true

    purse.rotation_degrees = 0
    purse.position = Vector2(0, 30)
    purse.scale = Vector2.ONE
    purse.flip_v = false

func _on_encounter_end():
    if StateManager.is_busted:
        queue_free()
    else:
        hide()
        $Camera2D.enabled = false


func _on_move(move: Meta.Moves):
    if move_timer.time_left > 0:
        return
    hud.disable_buttons()
    $SFX/Fight.play()
    
    var is_draw = false
    var enemy_move: Meta.Moves = Meta.Moves.values().pick_random()
    _play_animation(player, move)
    _play_animation(enemy, enemy_move)

    hud.clear_log()

    hud.append_log("You used " + Meta.get_move_name(move))
    hud.append_log("They used " + Meta.get_move_name(enemy_move))

    if move == Meta.Moves.Pull:
        purse.scale.x += .125
        purse.position.x -= 5
    if enemy_move == Meta.Moves.Pull:
        purse.scale.x += .125
        purse.position.x += 5
    
    if move == enemy_move:
        is_draw = true
        hud.append_log("Nothing happenned :/")
    elif move == Meta.Moves.Pull:
        if enemy_move == Meta.Moves.Hold:
            is_winner = true
            hud.append_log("You yanked the purse >:)")
        elif enemy_move == Meta.Moves.Push:
            hud.append_log("You fell down and lost the purse :(")
    elif move == Meta.Moves.Hold:
        if enemy_move == Meta.Moves.Push:
            is_winner = true
            hud.append_log("They slipped and lost the purse >:)")
        elif enemy_move == Meta.Moves.Pull:
            hud.append_log("They yanked the purse :(")
    elif move == Meta.Moves.Push:
        if enemy_move == Meta.Moves.Pull:
            is_winner = true
            hud.append_log("They fell down and lost the purse >:)")
        elif enemy_move == Meta.Moves.Hold:
            hud.append_log("You slipped and lost the purse :(")

    if is_draw:
        StateManager.player.increase_arthritis(1)
        hud.update_arthritis(StateManager.player.arthritis)
        if not StateManager.player.can_move():
            is_encounter_over = true
            _play_end_sound()
            move_timer.wait_time = 4
            hud.append_log("Your knee hurts :(")
            _play_animation(player, move, true)
            _play_win_animation.call_deferred(enemy)
    else:
        is_encounter_over = true
        _play_end_sound()
        move_timer.wait_time = 4
        if is_winner:
            _play_animation(enemy, enemy_move, true)
            _play_win_animation.call_deferred(player)
        else:
            _play_animation(player, move, true)
            _play_win_animation.call_deferred(enemy)

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
    
    purse.rotation_degrees = 90
    if is_winner:
        purse.position = Vector2(-75, 35)
    else:
        purse.position = Vector2(75, 35)
        purse.flip_v = true

func _play_end_sound():
    await get_tree().create_timer(1.0).timeout
    if is_winner:
        $SFX/Win.play()
    else:
        $SFX/Lose.play()

func _on_move_timer_timeout() -> void:
    if is_encounter_over:
        EventBus.on_encounter_end.emit(StateManager.encounter_enemy_id, is_winner)
    else:
        _play_animation(player, Meta.Moves.Hold)
        _play_animation(enemy, Meta.Moves.Hold)
        purse.scale.x = 1
        purse.position.x = 0
        hud.enable_buttons()

func _on_player_animation_finished():
    if not player.animation.ends_with("_end") and not is_winner:
        if player.animation != "hold_yoinked":
            $SFX/Oof.play()
        player.play(player.animation + "_end")

func _on_enemy_animation_finished():
    if not enemy.animation.ends_with("_end") and is_winner:
        if enemy.animation != "hold_yoinked":
            $SFX/Oof.play()
        enemy.play(enemy.animation + "_end")
