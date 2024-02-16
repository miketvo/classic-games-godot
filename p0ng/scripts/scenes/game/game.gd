extends GameScene2D


const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Paddle: PackedScene = preload("res://scenes/game/paddle.tscn")

var ball: RigidBody2D
var left_paddle: CharacterBody2D
var right_paddle: CharacterBody2D

@onready var _ball_spawn: Node2D = $Spawns/BallSpawn
@onready var _left_paddle_spawn: Node2D = $Spawns/LeftPaddleSpawn
@onready var _right_paddle_spawn: Node2D = $Spawns/RightPaddleSpawn


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _spawn_ball()
    _spawn_left_paddle()
    _spawn_right_paddle()

    $UI/GameUI/PauseMenuContainer/VBoxContainer/EndGameButton\
            .connect("pressed", _on_end_game_request)

func _process(_delta: float) -> void:
    pass
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $UI/GameUI/PauseMenuContainer/EndGameButton.pressed
func _on_end_game_request() -> void:
    scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _spawn_ball():
    ball = Ball.instantiate()
    ball.position = _ball_spawn.position
    add_child(ball)


func _spawn_left_paddle():
    left_paddle = Paddle.instantiate()
    left_paddle.position = _left_paddle_spawn.position
    add_child(left_paddle)


func _spawn_right_paddle():
    right_paddle = Paddle.instantiate()
    right_paddle.position = _right_paddle_spawn.position
    add_child(right_paddle)
#endregion
# ============================================================================ #
