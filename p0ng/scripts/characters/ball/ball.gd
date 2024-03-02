extends RigidBody2D


var _physics_frame_delta: float
@onready var _trajectory_predictor: Node2D = $TrajectoryPredictor


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    if get_tree().debug_collisions_hint:
        _trajectory_predictor.visible = true


func _process(_delta: float) -> void:
    var trajectory_line: Line2D = _trajectory_predictor.get_node("TrajectoryLine")
    trajectory_line.global_position = Vector2.ZERO


func _physics_process(delta: float) -> void:
    _physics_frame_delta = delta
    Global.game_state_data.ball_position = position
    Global.game_state_data.ball_velocity = linear_velocity


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    state.angular_velocity = 0.0
# ============================================================================ #


# ============================================================================ #
#region Utils
func predict_ball_position_at(x: float, max_frames: int) -> Vector2:
    var test_ball: RigidBody2D = _trajectory_predictor.get_node("TestBall")
    var trajectory_line: Line2D = _trajectory_predictor.get_node("TrajectoryLine")
    var current_position: Vector2 = global_position
    var current_velocity: Vector2 = linear_velocity

    trajectory_line.clear_points()
    for i in range(0, max_frames):
        trajectory_line.add_point(current_position)

        test_ball.global_position = current_position
        var collision: KinematicCollision2D = test_ball.move_and_collide(current_velocity, true)
        if collision:
            current_velocity = current_velocity.bounce(collision.get_normal())

        current_position += current_velocity * _physics_frame_delta
        if (current_velocity.dot(Vector2.RIGHT) > 0 and current_position.x > x)\
                or (current_velocity.dot(Vector2.RIGHT) < 0 and current_position.x < x):
            break

    if (current_velocity.dot(Vector2.RIGHT) > 0 and current_position.x < x)\
            or (current_velocity.dot(Vector2.RIGHT) < 0 and current_position.x > x):
        return Vector2.INF
    return current_position
# ============================================================================ #
