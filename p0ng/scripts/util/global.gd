extends Node


enum { SIDE_LEFT, SIDE_RIGHT }

enum GameMode {
    GAME_MODE_ONE_PLAYER_LEFT,
    GAME_MODE_ONE_PLAYER_RIGHT,
    GAME_MODE_TWO_PLAYERS,
}

enum ControlScheme { NONE, MAIN, ALT }


const UNIT_VECTORS: PackedVector2Array = [
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
    Vector2.RIGHT,
]

const PLAYER_SPEED: float = 600.0 ## Unit: px/s.
const BALL_SPEED_INITIAL: float = 450.0 ## Unit: px/s.
const BALL_SPEED_DIFFICULTY_MULTIPLIER: float = 1.15
const SERVING_ANGULAR_VARIATION: PackedFloat32Array = [-0.392699, 0.392699] ## Unit: radian.
const TARGET_SCORE: int = 7


var software_cursor_visibility: SoftwareCursor.Visibility\
        = SoftwareCursor.Visibility.ALWAYS_VISIBLE
var game_mode: GameMode


func flip_side(side: int) -> int:
    match side:
        SIDE_LEFT:
            return SIDE_RIGHT
        SIDE_RIGHT:
            return SIDE_LEFT
    assert(false, "Unrecognized side")
    return int(NAN)
