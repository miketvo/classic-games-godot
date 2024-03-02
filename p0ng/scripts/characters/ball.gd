extends RigidBody2D


var _delta: float


# ============================================================================ #
#region Godot builtins
func _physics_process(delta: float) -> void:
    _delta = delta
    Global.game_state_data.ball_position = position
    Global.game_state_data.ball_velocity = linear_velocity


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    state.angular_velocity = 0.0
# ============================================================================ #


# ============================================================================ #
#region Utils
func predict_ball_position_at(x: float) -> Vector2:
        return Vector2(x, 360.0)
# ============================================================================ #
