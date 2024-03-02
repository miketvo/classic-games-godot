extends Node2D


# ============================================================================ #
#region Enums
enum { SIDE_LEFT, SIDE_RIGHT, SIDE_UNDEFINED }
enum GameMode {
    GAME_MODE_ONE_PLAYER_LEFT,
    GAME_MODE_ONE_PLAYER_RIGHT,
    GAME_MODE_TWO_PLAYERS,
}
enum ControlScheme { NONE, MAIN, ALT, BOTH }
#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants
const UNIT_VECTORS: PackedVector2Array = [
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
    Vector2.RIGHT,
]
const PADDLE_SPEED: float = 600.0 ## Unit: px/s.
const BALL_SPEED_INITIAL: float = 450.0 ## Unit: px/s.
const BALL_SPEED_DIFFICULTY_MULTIPLIER: float = 1.15
const SERVING_ANGULAR_VARIATION: PackedFloat32Array = [-0.392699, 0.392699] ## Unit: radian.
const TARGET_SCORE: int = 7

## How far into the future ball trajectory prediction works. Lower numbers means
## higher performance, but the AI paddle will have worse reaction time. Higher
## number lowers performance, but the AI paddle will have a better reaction
## time.
const MAX_BALL_PRED_FRAMES: int = 60
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables
var software_cursor_visibility: SoftwareCursor.Visibility\
        = SoftwareCursor.Visibility.ALWAYS_VISIBLE
var current_game_mode: GameMode
var game_state_data: GameStateData = GameStateData.new()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func is_equal_approx(a: float, b: float, epsilon: float):
    return absf(a - b) < epsilon


func flip_side(side: int) -> int:
    match side:
        SIDE_LEFT:
            return SIDE_RIGHT
        SIDE_RIGHT:
            return SIDE_LEFT
    assert(false, "Unrecognized side")
    return int(NAN)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Game state data. Contains relevant information on the current state of the
## game, for use with a state machine.
class GameStateData extends Node:
    var ball_position: Vector2
    var ball_velocity: Vector2


    func get_ball_velocity_direction() -> Vector2:
        var direction_scalar = Vector2.RIGHT.dot(ball_velocity)
        return (Vector2.RIGHT * direction_scalar).normalized()


    func get_side_of_point(point: Vector2) -> int:
        if point.x < Global.get_viewport_rect().size.x / 2:
            return SIDE_LEFT
        if point.x > Global.get_viewport_rect().size.x / 2:
            return SIDE_RIGHT
        return SIDE_UNDEFINED
#endregion
# ============================================================================ #
