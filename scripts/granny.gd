class_name Classes

class Granny:
    var instance_id: int
    var arthritis: float = 0
    var max_arthritis: float
    var is_recovering: bool = false

    func init_values(p_instance_id: int, p_max_arthritis: float):
        instance_id = p_instance_id
        max_arthritis = p_max_arthritis

    static func init(p_instance_id: int, p_max_arthritis: float):
        var instance = Granny.new()
        instance.init_values(p_instance_id, p_max_arthritis)
        return instance

    func can_move():
        if is_recovering:
            return false
        return arthritis < max_arthritis

    func increase_arthritis(delta: float):
        arthritis += delta
        if arthritis >= max_arthritis:
            arthritis = max_arthritis
            is_recovering = true

    func decrease_arthritis(delta: float):
        if arthritis > 0:
            arthritis -= delta
            if is_recovering and arthritis <= (max_arthritis * .75):
                is_recovering = false
        else:
            arthritis = 0


class GrannyNpc extends Granny:
    var is_chasing: bool = false
    var is_avoiding: bool = false
    var is_stunned: bool = false
    
    static func init(p_instance_id: int, p_max_arthritis: float):
        var instance = GrannyNpc.new()
        instance.init_values(p_instance_id, p_max_arthritis)
        return instance

    func is_moving():
        return is_chasing or is_avoiding
