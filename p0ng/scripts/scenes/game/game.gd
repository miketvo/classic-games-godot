extends GameScene2D


const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Padde: PackedScene = preload("res://scenes/game/paddle.tscn")

@onready var _ball_spawn: Node2D = $Spawns/BallSpawn
@onready var _left_paddle_spawn: Node2D = $Spawns/LeftPaddleSpawn
@onready var _right_paddle_spawn: Node2D = $Spawns/RightPaddleSpawn


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    pass


func _process(delta: float) -> void:
    pass
#endregion
# ============================================================================ #
