class_name AIPaddle
extends AnimatableBody2D


# ============================================================================ #
#region Godot builtins
func _init() -> void:
    pass


func _physics_process(delta: float) -> void:
    var direction: float = 0

    var velocity: Vector2 = Vector2.DOWN * direction
    velocity *= Global.PLAYER_SPEED * delta

    move_and_collide(velocity)
#endregion
# ============================================================================ #
