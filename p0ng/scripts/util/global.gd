extends Node


# ============================================================================ #
#region Enums
enum { SIDE_LEFT, SIDE_RIGHT }
enum GameMode {
    GAME_MODE_ONE_PLAYER_LEFT,
    GAME_MODE_ONE_PLAYER_RIGHT,
    GAME_MODE_TWO_PLAYERS,
}
enum ControlScheme { NONE, MAIN, ALT }
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
class GameStateData extends Node2D:
    var ai_side: int
    var ball_position: Vector2
    var ball_velocity: Vector2


    func get_ball_side_location() -> Vector2:
        if ball_position.x < get_viewport_rect().size.x / 2:
            return Vector2.LEFT
        if ball_position.x > get_viewport_rect().size.x / 2:
            return Vector2.RIGHT
        return Vector2.ZERO


    func get_ball_velocity_direction() -> Vector2:
        var direction_scalar = Vector2.RIGHT.dot(ball_velocity)
        return (Vector2.RIGHT * direction_scalar).normalized()


    func project_ball_position_at(_y: float) -> Vector2:
        return Vector2.ZERO
#endregion
# ============================================================================ #
