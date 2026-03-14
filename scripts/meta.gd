extends Node

enum Moves {
    Pull, Hold, Push
}

func get_move_name(move: Moves):
    if move == Moves.Pull:
        return "Pull"
    if move == Moves.Hold:
        return "Hold"
    if move == Moves.Push:
        return "Push"