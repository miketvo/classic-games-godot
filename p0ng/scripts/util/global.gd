extends Node


enum {SIDE_LEFT, SIDE_RIGHT}

const UNIT_VECTORS: PackedVector2Array = [
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
    Vector2.RIGHT,
]

const PLAYER_SPEED: float = 600.0 ## Unit: px/s
const BALL_SPEED_INITIAL: float = 450.0 ## Unit: px/s
const BALL_SPEED_DIFFICULTY_MULTIPLIER: float = 1.15
const SERVING_ANGULAR_VARIATION: PackedFloat32Array = [-0.392699, 0.392699] ## Unit: radian
const TARGET_SCORE: int = 5


func flip_side(side: int) -> int:
    match side:
        SIDE_LEFT:
            return SIDE_RIGHT
        SIDE_RIGHT:
            return SIDE_LEFT
    assert(false, "Unrecognized side")
    return int(NAN)
