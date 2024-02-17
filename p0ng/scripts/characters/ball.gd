extends RigidBody2D


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    state.angular_velocity = 0.0
