extends Node

signal on_encounter_start(instance_id: int)
signal on_encounter_end(instance_id: int, is_purse_stolen: bool)
signal on_enemy_left()