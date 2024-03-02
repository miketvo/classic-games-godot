extends State


@export var tolerance: float = 12.0
@export var character_component: AnimatableBody2D


# ============================================================================ #
#region State builtins
func _enter() -> void:
    assert(character_component, "character_component must be assigned")


func _physics_update(delta: float, game_state_data: Global.GameStateData) -> void:
    var current_position = character_component.global_position
    var ball_y_pred: float = game_state_data.predict_ball_position_at.call(current_position.x).y
    var at_ball_y_pred: bool = Global.is_equal_approx(
            character_component.position.y,
            ball_y_pred,
            tolerance
    )

    if not at_ball_y_pred:
        var direction_to_ball_y: float = ball_y_pred - current_position.y
        var velocity: Vector2 = (Vector2.DOWN * direction_to_ball_y).normalized()
        velocity *= Global.PADDLE_SPEED * delta
        character_component.move_and_collide(velocity)
    else:
        character_component.move_and_collide(Vector2.ZERO)

    var ai_side: int = game_state_data.ai_side
    var ball_heading: Vector2 = game_state_data.get_ball_velocity_direction()
    match [ ai_side, ball_heading ]:
        [ Global.SIDE_LEFT, Vector2.RIGHT ], [ Global.SIDE_RIGHT, Vector2.LEFT ]:
            transitioned.emit(self, "PrepareState")
# ============================================================================ #
