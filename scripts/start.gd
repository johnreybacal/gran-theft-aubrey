extends Node2D


func _ready() -> void:
    StateManager.is_encountered = false
    StateManager.encounter_enemy_id = -1
    StateManager.player = null
    StateManager.enemies = []
    StateManager.enemies_defeated = []
    StateManager.police_arriving_count = 0
    StateManager.is_busted = false
    StateManager.is_end = false
    StateManager.interactable_id = -1
    StateManager.interactables = []


func _on_start_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/game_explore.tscn")
