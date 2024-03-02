extends State


@export var tolerance: float = 32.0  ## Unit: px.
@export var variance: float = 10.0  ## Unit: px.
@export var character_component: AnimatableBody2D

var _rng: RandomNumberGenerator
var _ball_position_pred: Vector2
var _variation: float

@onready var _trajectory_predictor: Node2D = $TrajectoryPredictor


# ============================================================================ #
#region State builtins
func _enter() -> void:
    assert(character_component, "character_component must be assigned")
    _rng = RandomNumberGenerator.new()
    _ball_position_pred = Vector2.INF
    _variation = _rng.randfn(0.0, variance)
    if get_tree().debug_collisions_hint:
        _trajectory_predictor.visible = true


func _exit() -> void:
    var trajectory_line: Line2D = _trajectory_predictor.get_node("TrajectoryLine")
    trajectory_line.clear_points()
    if get_tree().debug_collisions_hint:
        _trajectory_predictor.visible = false


func _physics_update(delta: float, game_state_data: Global.GameStateData) -> void:
    var current_position = character_component.global_position
    _ball_position_pred = _predict_ball_position_at(
            current_position.x,
            Global.MAX_BALL_PRED_FRAMES,
            delta
    ) if _ball_position_pred == Vector2.INF else _ball_position_pred

    var at_ball_y_pred: bool = (_ball_position_pred == Vector2.INF) or Global.is_equal_approx(
            character_component.global_position.y,
            _ball_position_pred.y + _variation,
            tolerance
    )

    if not at_ball_y_pred:
        var direction_to_ball_y: float = _ball_position_pred.y - current_position.y
        var velocity: Vector2 = (Vector2.DOWN * direction_to_ball_y).normalized()
        velocity *= Global.PADDLE_SPEED * delta
        character_component.move_and_collide(velocity)
    else:
        character_component.move_and_collide(Vector2.ZERO)

    var current_side: int = game_state_data.get_side_of_point(character_component.global_position)
    var ball_heading: Vector2 = game_state_data.get_ball_velocity_direction()
    match [ current_side, ball_heading ]:
        [ Global.SIDE_LEFT, Vector2.RIGHT ], [ Global.SIDE_RIGHT, Vector2.LEFT ]:
            transitioned.emit(self, "PrepareState")
# ============================================================================ #


# ============================================================================ #
#region Utils
func _predict_ball_position_at(x: float, max_frames: int, delta: float) -> Vector2:
    var test_ball: RigidBody2D = _trajectory_predictor.get_node("TestBall")
    var trajectory_line: Line2D = _trajectory_predictor.get_node("TrajectoryLine")
    var current_position: Vector2 = Global.game_state_data.ball_position
    var current_velocity: Vector2 = Global.game_state_data.ball_velocity

    trajectory_line.clear_points()
    for i in range(0, max_frames):
        trajectory_line.add_point(current_position)

        test_ball.global_position = current_position
        var collision: KinematicCollision2D = test_ball.move_and_collide(
                current_velocity * delta,
                true
        )
        if collision:
            current_velocity = current_velocity.bounce(collision.get_normal())

        current_position += current_velocity * delta
        if (current_velocity.dot(Vector2.RIGHT) > 0 and current_position.x > x)\
                or (current_velocity.dot(Vector2.RIGHT) < 0 and current_position.x < x):
            break

    if (current_velocity.dot(Vector2.RIGHT) > 0 and current_position.x < x)\
            or (current_velocity.dot(Vector2.RIGHT) < 0 and current_position.x > x):
        return Vector2.INF
    return current_position
# ============================================================================ #
