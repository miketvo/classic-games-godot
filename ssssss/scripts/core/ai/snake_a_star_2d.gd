class_name SnakeAStar2D
extends AStar2D


# ============================================================================ #
#region Godot builtins
func _compute_cost(from_id: int, to_id: int) -> float:
    var from_position: Vector2 = get_point_position(from_id)
    var to_position: Vector2 = get_point_position(to_id)
    var direction: Vector2 = (to_position - from_position).normalized()
    var horizontal: bool = Vector2.UP.dot(direction) == 0

    # Prefer horizontal movement over vertical movement.
    if horizontal:
        return 1.0
    else:
        return 2.0


func _estimate_cost(from_id: int, to_id: int) -> float:
    return _compute_cost(from_id, to_id)
#endregion
# ============================================================================ #
