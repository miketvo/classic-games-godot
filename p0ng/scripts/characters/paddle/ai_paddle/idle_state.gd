extends State


var _is_ready: bool
@onready var _cooldown_timer: Timer = $CooldownTimer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _cooldown_timer.connect("timeout", _on_cooldown_timer_timeout)
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    _is_ready = false
    _cooldown_timer.start()


func _physics_update(_delta: float, game_state_data: Global.GameStateData) -> void:
    if _is_ready:
        var ai_side: int = game_state_data.ai_side
        var ball_heading: Vector2 = game_state_data.get_ball_velocity_direction()

        match [ ai_side, ball_heading ]:
            [ Global.SIDE_LEFT, Vector2.RIGHT ], [ Global.SIDE_RIGHT, Vector2.LEFT ]:
                transitioned.emit(self, "PrepareState")
            [ Global.SIDE_LEFT, Vector2.LEFT ], [ Global.SIDE_RIGHT, Vector2.RIGHT ]:
                transitioned.emit(self, "InterceptState")
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _cooldown_timer.timeout().
func _on_cooldown_timer_timeout():
    _is_ready = true

#endregion
# ============================================================================ #
