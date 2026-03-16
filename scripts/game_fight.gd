extends Node2D

@onready var hud: HudFight = $CanvasLayer/HudFight

func _ready() -> void:
    EventBus.on_encounter_start.connect(_on_encounter_start.unbind(1))
    EventBus.on_encounter_end.connect(hide.unbind(2))
    hide()

    hud.set_max_arthritis(StateManager.player.max_arthritis)
    hud.move_selected.connect(_on_move)

func _on_visibility_changed() -> void:
    $CanvasLayer.visible = visible

func _on_encounter_start():
    show()
    hud.clear_log()
    hud.update_arthritis(StateManager.player.arthritis)

func _on_move(move: Meta.Moves):
    var is_winner = false
    # var is_draw = false
    var is_draw = true
    var enemy_move: Meta.Moves = Meta.Moves.values().pick_random()

    hud.append_log("You used " + Meta.get_move_name(move) + " | Enemy used " + Meta.get_move_name(enemy_move))
    
    # if move == enemy_move:
    #     is_draw = true
    #     hud.append_log("DRAW: Nothing happenned")
    # elif move == Meta.Moves.Pull:
    #     if enemy_move == Meta.Moves.Hold:
    #         is_winner = true
    #         hud.append_log("WIN: You yanked the purse")
    #     elif enemy_move == Meta.Moves.Push:
    #         hud.append_log("LOST: You fell down and lost the purse")
    # elif move == Meta.Moves.Hold:
    #     if enemy_move == Meta.Moves.Push:
    #         is_winner = true
    #         hud.append_log("WIN: Enemy slipped and lost the purse")
    #     elif enemy_move == Meta.Moves.Pull:
    #         hud.append_log("LOST: Enemy yanked the purse")
    # elif move == Meta.Moves.Push:
    #     if enemy_move == Meta.Moves.Pull:
    #         is_winner = true
    #         hud.append_log("WIN: Enemy fell down and lost the purse")
    #     elif enemy_move == Meta.Moves.Hold:
    #         hud.append_log("LOST: You slipped and lost the purse")

    if is_draw:
        StateManager.player.increase_arthritis(1)
        hud.update_arthritis(StateManager.player.arthritis)
        if not StateManager.player.can_move():
            hud.append_log("LOST: Your knee hurts")
            EventBus.on_encounter_end.emit.call_deferred(StateManager.encounter_enemy_id, false)
    else:
        EventBus.on_encounter_end.emit(StateManager.encounter_enemy_id, is_winner)
