class_name PlayerPaddle
extends CharacterBody2D


enum {NONE, PLAYER_LEFT, PLAYER_RIGHT}

@export var player_id: int
var _not_controllable_warned: bool


# ============================================================================ #
#region Godot builtins
func _init() -> void:
    _not_controllable_warned = false
    player_id = NONE


func _physics_process(_delta: float) -> void:
    var direction: float = 0
    match player_id:
        PLAYER_LEFT:
            direction = Input.get_axis("p_left_move_up", "p_left_move_down")
        PLAYER_RIGHT:
            direction = Input.get_axis("p_right_move_up", "p_right_move_down")
        _:
            if not _not_controllable_warned:
                push_warning("PlayerPaddle %s is not controllable" % self.to_string())
                _not_controllable_warned = true
            return

    if direction:
        velocity.y = direction * Global.PLAYER_SPEED
    else:
        velocity.y = direction * Global.PLAYER_SPEED

    move_and_slide() # Already accounted for delta
#endregion
# ============================================================================ #
