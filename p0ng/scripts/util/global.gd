extends Node


enum {SIDE_LEFT, SIDE_RIGHT}


const UNIT_VECTORS: PackedVector2Array = [
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
    Vector2.RIGHT,
]

const PLAYER_SPEED: float = 450.0 ## Unit: px/s
const BALL_SPEED_INITIAL: float = 450.0 ## Unit: px/s
const BALL_SPEED_STEP_INCREMENT: float = 50.0 ## Unit: px/s
const FIRST_SIDE_SERVED: int = SIDE_RIGHT
const TARGET_SCORE: int = 11
