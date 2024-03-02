extends State


@export var tolerance: float = 16.0  ## Unit: px.
@export var character_component: AnimatableBody2D

var _middle_position: Vector2


# ============================================================================ #
#region State builtins
func _enter() -> void:
    assert(character_component, "character_component must be assigned")
    _middle_position = Vector2(
            character_component.global_position.x,
            character_component.get_viewport_rect().size.y / 2
    )


func _physics_update(delta: float, game_state_data: Global.GameStateData) -> void:
    var current_position = character_component.global_position
    var at_middle_position: bool = Global.is_equal_approx(
            current_position.distance_squared_to(_middle_position),
            0.0,
            tolerance
    )

    if not at_middle_position:
        var angle_to_middle_position: float = current_position.angle_to_point(_middle_position)
        var velocity: Vector2 = Vector2.RIGHT.rotated(angle_to_middle_position)
        velocity *= Global.PADDLE_SPEED * delta
        character_component.move_and_collide(velocity)
    else:
        character_component.move_and_collide(Vector2.ZERO)

    var ai_side: int = game_state_data.ai_side
    var ball_heading: Vector2 = game_state_data.get_ball_velocity_direction()
    match [ ai_side, ball_heading ]:
        [ Global.SIDE_LEFT, Vector2.LEFT ], [ Global.SIDE_RIGHT, Vector2.RIGHT ]:
            transitioned.emit(self, "InterceptState")
# ============================================================================ #
