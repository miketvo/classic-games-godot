extends State


# ============================================================================ #
#region State builtins
func _physics_update(_delta: float, game_state_data: Global.GameStateData) -> void:
    var ai_side: int = game_state_data.ai_side
    var ball_heading: Vector2 = game_state_data.get_ball_velocity_direction()

    match [ ai_side, ball_heading ]:
        [ Global.SIDE_LEFT, Vector2.RIGHT ], [ Global.SIDE_RIGHT, Vector2.LEFT ]:
            transitioned.emit(self, "PrepareState")
        [ Global.SIDE_LEFT, Vector2.LEFT ], [ Global.SIDE_RIGHT, Vector2.RIGHT ]:
            transitioned.emit(self, "InterceptState")
# ============================================================================ #
