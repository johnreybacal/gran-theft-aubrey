class_name Classes

class Granny:
    var instance_id: int
    var arthritis: float = 0
    var max_arthritis: float = 5
    var arthritis_rate: float = 1
    var arthritis_rate_penalty: float = .0
    var recovery_threshold: float = .75
    var is_recovering: bool = false
    var stats: GrannyStats
    var sprite: AnimatedSprite2D

    func init_values(p_instance_id: int, p_stats: GrannyStats, p_sprite: AnimatedSprite2D, p_arthritis_rate: float = 1):
        instance_id = p_instance_id
        arthritis_rate = p_arthritis_rate
        stats = p_stats
        sprite = p_sprite
        stats.set_max_arthritis(max_arthritis)
        stats.update_arthritis(0)

    static func init(p_instance_id: int, p_stats: GrannyStats, p_sprite: AnimatedSprite2D, p_arthritis_rate: float = 1):
        var instance = Granny.new()
        instance.init_values(p_instance_id, p_stats, p_sprite, p_arthritis_rate)
        return instance

    func can_move():
        if is_recovering:
            return false
        return arthritis < max_arthritis

    func increase_arthritis(delta: float):
        arthritis += delta * (arthritis_rate + arthritis_rate_penalty)
        if arthritis >= max_arthritis:
            arthritis = max_arthritis
            is_recovering = true
            recovery_threshold = randf_range(.5, .9)
            stats.on_knees_hurt()
            play_knees_hurt()
        stats.update_arthritis(arthritis)
        _update_arthritis_rate_penalty()

    func decrease_arthritis(delta: float):
        if arthritis > 0:
            arthritis -= delta
            if is_recovering and arthritis <= (max_arthritis * recovery_threshold):
                is_recovering = false
                stats.on_knees_hurt_end()
                play_idle()
        else:
            arthritis = 0
        stats.update_arthritis(arthritis)
        _update_arthritis_rate_penalty()

    func _update_arthritis_rate_penalty():
        arthritis_rate_penalty = (arthritis / max_arthritis) / 2

    func play_walk(is_facing_left: bool):
        sprite.play("walk")
        sprite.flip_h = is_facing_left

    func play_idle():
        sprite.play("idle")

    func play_knees_hurt():
        sprite.play("knees_hurt")


class GrannyNpc extends Granny:
    var is_chasing: bool = false
    var is_avoiding: bool = false
    var is_stunned: bool = false
    var is_stolen: bool = false
    var is_leaving: bool = false
    var encounter_count: int = 0
    
    static func init(p_instance_id: int, p_stats: GrannyStats, p_sprite: AnimatedSprite2D, p_arthritis_rate: float = 1):
        var instance = GrannyNpc.new()
        instance.init_values(p_instance_id, p_stats, p_sprite, p_arthritis_rate)
        return instance

    func can_move():
        return super.can_move() and not is_stunned

    func is_on_the_move():
        return is_chasing or is_avoiding or is_leaving

    func can_encounter():
        if is_leaving:
            return false
        if not is_stolen:
            return true
        return is_chasing

    func on_encounter_end(is_loser: bool):
        is_stolen = is_loser
        
        encounter_count += 1

        is_chasing = false
        is_avoiding = false
        is_leaving = false

        if encounter_count > 2:
            is_leaving = true
            stats.on_leaving()
        if is_loser:
            if not is_leaving:
                is_chasing = true
                is_stunned = true
                stats.on_stunned()
                stats.on_chasing()
            if self not in StateManager.enemies_defeated:
                StateManager.enemies_defeated.append(self )
            EventBus.on_purse_stolen_updated.emit()
        else:
            if not is_leaving:
                is_avoiding = true
                stats.on_avoiding()
            if self in StateManager.enemies_defeated:
                var index: int = StateManager.enemies_defeated.find(self )
                if index != -1:
                    StateManager.enemies_defeated.remove_at(index)
                    EventBus.on_purse_stolen_updated.emit()
