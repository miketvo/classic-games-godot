extends GameScene2D


const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Paddle: PackedScene = preload("res://scenes/game/paddle.tscn")
const PlayerPaddleScript: Script = preload("res://scripts/characters/player_paddle.gd")

var ball: RigidBody2D
var left_paddle: CharacterBody2D
var right_paddle: CharacterBody2D

var _ball_active: bool

@onready var _ball_spawn: Node2D = $Spawns/BallSpawn
@onready var _left_paddle_spawn: Node2D = $Spawns/LeftPaddleSpawn
@onready var _right_paddle_spawn: Node2D = $Spawns/RightPaddleSpawn


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _spawn_left_paddle()
    _spawn_right_paddle()
    _spawn_ball()
    _ball_active = false

    $UI/GameUI/PauseMenuContainer/VBoxContainer/RestartButton\
            .connect("pressed", _on_restart_request)
    $UI/GameUI/PauseMenuContainer/VBoxContainer/EndGameButton\
            .connect("pressed", _on_end_game_request)

func _physics_process(delta: float) -> void:
    if not _ball_active:
        _serve_ball(delta, Global.INITIAL_BALL_SPEED)
        _ball_active = true
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $UI/GameUI/PauseMenuContainer/RestartButton.pressed
func _on_restart_request() -> void:
    scene_finished.emit(SceneKey.GAME)

## Listens to $UI/GameUI/PauseMenuContainer/EndGameButton.pressed
func _on_end_game_request() -> void:
    scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _spawn_left_paddle() -> void:
    left_paddle = Paddle.instantiate()
    left_paddle.set_script(PlayerPaddleScript)
    left_paddle.position = _left_paddle_spawn.position
    left_paddle.player_id = PlayerPaddle.PLAYER_LEFT
    add_child(left_paddle)


func _spawn_right_paddle() -> void:
    right_paddle = Paddle.instantiate()
    right_paddle.set_script(PlayerPaddleScript)
    right_paddle.position = _right_paddle_spawn.position
    right_paddle.player_id = PlayerPaddle.PLAYER_RIGHT
    add_child(right_paddle)


func _spawn_ball() -> void:
    ball = Ball.instantiate()
    ball.position = _ball_spawn.position
    add_child(ball)


## Serve the ball to the side of the game defined in
## [constant Global.FIRST_SIDE_SERVED], taking [param delta] into account.
func _serve_ball(
        delta: float,
        delta_speed: float = 0.0,
        angular_deviation: float = 0.0
) -> void:
    var base_vector = Vector2.LEFT if Global.FIRST_SIDE_SERVED == Global.SIDE_LEFT\
            else Vector2.RIGHT
    base_vector = base_vector.rotated(angular_deviation)

    # a = delta(speed) / delta(time) (px/s^2)
    var acceleration: float = delta_speed / (delta * Engine.physics_ticks_per_second)
    var impulse = base_vector * ball.mass * acceleration # F = m * a (Newton)

    ball.apply_central_impulse(impulse)
#endregion
# ============================================================================ #
