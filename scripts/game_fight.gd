extends Node2D

@onready var hud: HudFight = $CanvasLayer/HudFight

func _ready() -> void:
    EventBus.toggle_encounter.connect(_on_encounter)
    hide()

    hud.move_selected.connect(_on_move)

func _on_encounter(is_encountered: bool):
    if is_encountered:
        hud.clear_log()
        show()
    else:
        hide()

func _on_visibility_changed() -> void:
    $CanvasLayer.visible = visible

func _on_move(move: Meta.Moves):
    var is_winner = false
    var enemy_move: Meta.Moves = Meta.Moves.values().pick_random()

    hud.append_log("You used " + Meta.get_move_name(move) + " | Enemy used " + Meta.get_move_name(enemy_move))
    
    if move == enemy_move:
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

    if is_winner:
        EventBus.toggle_encounter.emit(false)