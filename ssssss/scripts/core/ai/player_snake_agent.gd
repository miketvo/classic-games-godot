class_name PlayerSnakeAgent
extends SnakeAgent
## Player-controlled [SnakeAgent].


# ============================================================================ #
#region SnakeAgent builtins
func _get_action(state: Global.GameStateData) -> Global.Direction:
    if state.player_control_queue.size() == 0:
        return Global.Direction.NONE

    var action: Global.Direction = state.player_control_queue.pop_front()
    var snake_head: Vector2i = state.world.snakes[_snake_id][0]
    var next_movement: Vector2i = Global.DIRECTIONS[action]
    if snake_head + next_movement != state.world.snakes[_snake_id][1]:
        return action
    return Global.Direction.NONE
#endregion
# ============================================================================ #
