extends AnimatableBody2D


@export var player_control_scheme: Global.ControlScheme
var _not_controllable_warned: bool


# ============================================================================ #
#region Godot builtins
func _init() -> void:
    _not_controllable_warned = false
    player_control_scheme = Global.ControlScheme.NONE


func _physics_process(delta: float) -> void:
    var direction: float = 0
    match player_control_scheme:
        Global.ControlScheme.MAIN:
            direction = Input.get_axis("p_left_move_up", "p_left_move_down")
        Global.ControlScheme.ALT:
            direction = Input.get_axis("p_right_move_up", "p_right_move_down")
        _:
            if not _not_controllable_warned:
                push_warning("PlayerPaddle %s is not controllable" % self.to_string())
                _not_controllable_warned = true
            return

    var velocity: Vector2 = Vector2.DOWN * direction
    velocity *= Global.PLAYER_SPEED * delta

    move_and_collide(velocity)
#endregion
# ============================================================================ #
