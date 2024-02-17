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
const BALL_SPEED_DIFFICULTY_MULTIPLIER: float = 1.15
const FIRST_SIDE_SERVED: int = SIDE_RIGHT
const SERVING_ANGULAR_VARIATION: PackedFloat32Array = [-0.785398, 0.785398] ## Unit: radian
const TARGET_SCORE: int = 11
