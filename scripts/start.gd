extends Node2D

@onready var speech: Label = $Speech

var phrase = "Oh dear, Here we go again"
var phrase_len = len(phrase)
var is_starting = false
var type_interval = .05
var phrase_index = 0

func _ready() -> void:
    speech.text = "";
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


func _process(delta: float) -> void:
    if is_starting:
        if phrase_index < phrase_len:
            type_interval -= delta
            if type_interval <= 0:
                speech.text = phrase.substr(0, phrase_index + 1)

                if phrase[phrase_index] == ",":
                    type_interval = 1
                else:
                    type_interval = .05

                phrase_index += 1
        else:
            await get_tree().create_timer(1.0).timeout
            get_tree().change_scene_to_file("res://scenes/game_explore.tscn")


func _on_start_button_pressed() -> void:
    $StartButton.disabled = true
    $StartButton.visible = false
    is_starting = true
