extends RigidBody2D


# ============================================================================ #
#region Godot builtins
func _physics_process(_delta: float) -> void:
    Global.game_state_data.ball_position = position
    Global.game_state_data.ball_velocity = linear_velocity


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    state.angular_velocity = 0.0
# ============================================================================ #
