extends GameScene2D


# ============================================================================ #
#region Enums, Constants & Variables
enum {
    GAME_STATE_NORMAL,
    GAME_STATE_DEUCE,
}

const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Paddle: PackedScene = preload("res://scenes/game/paddle.tscn")
const PlayerPaddleScript: Script = preload("res://scripts/characters/player_paddle.gd")

@export var game_point_text: String

var ball: RigidBody2D
var left_paddle: AnimatableBody2D
var right_paddle: AnimatableBody2D
var left_score: int
var right_score: int

var _rng = RandomNumberGenerator.new()
var _ball_speed: float
var _game_over: bool
var _round_started: bool
var _side_served: int
var _game_state: int
var _game_round: int

## 2-bit bitwise flag, left and right sides correspond to leftmost and rightmost bit.
var _game_point_state: int

@onready var _software_cursor: SoftwareCursor = get_tree().root.get_node("Main/SoftwareCursor")
@onready var _ball_spawn: Node2D = $Spawns/BallSpawn
@onready var _left_paddle_spawn: Node2D = $Spawns/LeftPaddleSpawn
@onready var _right_paddle_spawn: Node2D = $Spawns/RightPaddleSpawn
@onready var _score_label: Dictionary = {
    Global.SIDE_LEFT: $UI/GameUI/HUDContainer/LeftScore,
    Global.SIDE_RIGHT: $UI/GameUI/HUDContainer/RightScore,
}
@onready var _endgame_dialog: Container = $UI/GameUI/EndGameDialogContainer
@onready var _win_label: Dictionary = {
    Global.SIDE_LEFT: $UI/GameUI/EndGameDialogContainer/MessageContainer/LeftContainer/WinLabel,
    Global.SIDE_RIGHT: $UI/GameUI/EndGameDialogContainer/MessageContainer/RightContainer/WinLabel,
}
@onready var _lose_label: Dictionary = {
    Global.SIDE_LEFT: $UI/GameUI/EndGameDialogContainer/MessageContainer/LeftContainer/LoseLabel,
    Global.SIDE_RIGHT: $UI/GameUI/EndGameDialogContainer/MessageContainer/RightContainer/LoseLabel,
}
#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _spawn_left_paddle()
    _spawn_right_paddle()
    _configure_world()
    _configure_ui()
    _configure_game()


func _process(_delta: float) -> void:
    var left_score_label_text: String = "%s%d" %\
            [ game_point_text + " " if not _game_point_state ^ 0b10 else "", left_score ]
    _score_label[Global.SIDE_LEFT].text = left_score_label_text
    var right_score_label_text: String = "%d%s" %\
            [ right_score, " " + game_point_text if not _game_point_state ^ 0b01 else "" ]
    _score_label[Global.SIDE_RIGHT].text = right_score_label_text

    if _game_over:
        _software_cursor.visibility = SoftwareCursor.Visibility.ALWAYS_VISIBLE
        _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton").grab_focus()
        _endgame_dialog.process_mode = Node.PROCESS_MODE_INHERIT
        UI.tween_transition_fade_appear_container(
                _endgame_dialog,
                UI.UI_TRANSITION_DURATION / 4
        ).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        $UI/GameUI.disable_pausing = true
        get_tree().paused = true


func _physics_process(delta: float) -> void:
    if not _round_started and not _game_over:
        _spawn_ball()
        _serve_ball(
                delta,
                Global.BALL_SPEED_INITIAL,
                _side_served,
                Global.SERVING_ANGULAR_VARIATION
        )
        _round_started = true
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to ball.body_entered(body: Node).
func _on_ball_body_entered(body: Node) -> void:
    var top_bound = $World/TopBound
    var bottom_bound = $World/BottomBound

    match body:
        top_bound:
            top_bound.get_node("Sprite2D/AnimationPlayer").play("active")
            top_bound.get_node("Sprite2D/AnimationPlayer").queue("idle")
        bottom_bound:
            bottom_bound.get_node("Sprite2D/AnimationPlayer").play("active")
            bottom_bound.get_node("Sprite2D/AnimationPlayer").queue("idle")
        left_paddle:
            left_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
            left_paddle.get_node("Sprite2D/AnimationPlayer").queue("idle")
        right_paddle:
            right_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
            right_paddle.get_node("Sprite2D/AnimationPlayer").queue("idle")


## Listens to ball.body_exited(body: Node).
func _on_ball_body_exited(body: Node) -> void:
    var new_velocity: Vector2
    match body:
        left_paddle, right_paddle:
            _ball_speed *= Global.BALL_SPEED_DIFFICULTY_MULTIPLIER
            new_velocity =\
                    Vector2.from_angle(ball.linear_velocity.angle())\
                    * _ball_speed
        _:
            new_velocity =\
                    Vector2.from_angle(ball.linear_velocity.angle())\
                    * _ball_speed
    ball.linear_velocity = new_velocity


## Listens to $World/VerticalSeparator.body_entered(body: Node).
func _on_vertical_separator_body_entered(body: Node) -> void:
    if body == ball:
        $World/VerticalSeparator/Sprite2D/AnimationPlayer.play("active")
        $World/VerticalSeparator/Sprite2D/AnimationPlayer.queue("idle")


## Listens to $World/VerticalSeparator.body_entered(body: Node).
func _on_left_bound_body_entered(body: Node) -> void:
    if body == ball:
        _win_round(Global.SIDE_RIGHT)


## Listens to $World/VerticalSeparator.body_entered(body: Node).
func _on_right_bound_body_entered(body: Node) -> void:
    if body == ball:
        _win_round(Global.SIDE_LEFT)


## Listens to $UI/GameUI/PauseMenuContainer/RestartButton.pressed() and
## _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton").pressed().
func _on_restart_request() -> void:
    get_tree().paused = false
    scene_finished.emit(SceneKey.GAME)


## Listens to $UI/GameUI/PauseMenuContainer/EndGameButton.pressed() and
## _endgame_dialog.get_node("MenuContainer/VBoxContainer/BackToMainMenuButton").pressed().
func _on_end_game_request() -> void:
    get_tree().paused = false
    scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _spawn_left_paddle() -> void:
    left_paddle = Paddle.instantiate()
    left_paddle.set_script(PlayerPaddleScript)
    left_paddle.position = _left_paddle_spawn.position
    left_paddle.rotation = PI
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
    ball.connect("body_entered", _on_ball_body_entered)
    ball.connect("body_exited", _on_ball_body_exited)
    _ball_speed = Global.BALL_SPEED_INITIAL
    _round_started = false
    add_child(ball)


## Serve the ball to the side of the game defined in [param direction], taking
## [param delta] into account. Meant to be called after
## [method Game._spawn_ball].
func _serve_ball(
        delta: float,
        delta_speed: float,
        direction: int,
        angular_variation: PackedFloat32Array = [0.0, 0.0]
) -> void:
    var unit_vector: Vector2
    match direction:
        Global.SIDE_LEFT:
            unit_vector = Vector2.LEFT
        Global.SIDE_RIGHT:
            unit_vector = Vector2.RIGHT
        _:
            assert(false, "Unrecognized side")
    unit_vector = unit_vector.rotated(_rng.randf_range(
            angular_variation[0],
            angular_variation[1]
    ))

    # a = delta(speed) / delta(time) (px/s^2)
    var acceleration: float = delta_speed / (delta * Engine.physics_ticks_per_second)
    var impulse = unit_vector * ball.mass * acceleration # F = m * a (Newton)

    ball.apply_central_impulse(impulse)
#endregion


func _despawn_ball() -> void:
    ball.queue_free()
    remove_child(ball)


func _configure_world() -> void:
    $World/LeftBound.connect(
            "body_entered",
            _on_left_bound_body_entered
    )
    $World/RightBound.connect(
            "body_entered",
            _on_right_bound_body_entered
    )


func _configure_ui() -> void:
    _software_cursor.visibility = SoftwareCursor.Visibility.IDLE_AUTO_HIDE
    _endgame_dialog.process_mode = Node.PROCESS_MODE_DISABLED
    _endgame_dialog.modulate = Color(1.0, 1.0, 1.0, 0.0)
    _win_label[Global.SIDE_LEFT].hide()
    _win_label[Global.SIDE_RIGHT].hide()
    _lose_label[Global.SIDE_LEFT].hide()
    _lose_label[Global.SIDE_RIGHT].hide()

    $UI/GameUI/PauseMenuContainer/VBoxContainer/RestartButton\
            .connect("pressed", _on_restart_request)
    $UI/GameUI/PauseMenuContainer/VBoxContainer/EndGameButton\
            .connect("pressed", _on_end_game_request)
    _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton")\
            .connect("pressed", _on_restart_request)
    _endgame_dialog.get_node("MenuContainer/VBoxContainer/BackToMainMenuButton")\
            .connect("pressed", _on_end_game_request)


func _configure_game() -> void:
    left_score = 0
    right_score = 0
    _game_over = false
    _side_served = _rng.randi_range(Global.SIDE_LEFT, Global.SIDE_RIGHT)
    _game_state = GAME_STATE_NORMAL
    _game_round = 0
    _game_point_state = 0b00


func _win_round(winning_side: int) -> void:
    match winning_side:
        Global.SIDE_LEFT:
            left_score += 1
        Global.SIDE_RIGHT:
            right_score += 1
        _:
            assert(false, "Unrecognized side")

    _despawn_ball()
    _round_started = false

    const GAME_SCORE: int = Global.TARGET_SCORE - 1
    if left_score == GAME_SCORE and right_score == GAME_SCORE:
        _game_state = GAME_STATE_DEUCE

    _game_point_state = 0b00
    match [ left_score, right_score, left_score - right_score, _game_state ]:
        [ GAME_SCORE, _, _, GAME_STATE_NORMAL ] when left_score > right_score:
            _game_point_state = 0b10
        [ _, GAME_SCORE, _, GAME_STATE_NORMAL ] when left_score < right_score:
            _game_point_state = 0b01
        [ _, _, 1, GAME_STATE_DEUCE]:
            _game_point_state = 0b10
        [ _, _, -1, GAME_STATE_DEUCE]:
            _game_point_state = 0b01

    match _game_state:
        GAME_STATE_NORMAL:
            if left_score == Global.TARGET_SCORE:
                _win_game(Global.SIDE_LEFT)
                return
            if right_score == Global.TARGET_SCORE:
                _win_game(Global.SIDE_RIGHT)
                return
        GAME_STATE_DEUCE:
            if left_score - right_score == 2:
                _win_game(Global.SIDE_LEFT)
                return
            if left_score - right_score == -2:
                _win_game(Global.SIDE_RIGHT)
                return

    if _game_state == GAME_STATE_NORMAL:
        if (_game_round - 1) % 2 == 0:
            _side_served = Global.flip_side(_side_served)
    elif _game_state == GAME_STATE_DEUCE:
        _side_served = Global.flip_side(_side_served)

    _game_round += 1


func _win_game(winning_side: int) -> void:
    match winning_side:
        Global.SIDE_LEFT:
            _win_label[Global.SIDE_LEFT].show()
            _lose_label[Global.SIDE_RIGHT].show()
        Global.SIDE_RIGHT:
            _win_label[Global.SIDE_RIGHT].show()
            _lose_label[Global.SIDE_LEFT].show()
        _:
            assert(false, "Unrecognized side")

    left_paddle.set_script(null)
    right_paddle.set_script(null)
    _game_over = true
# ============================================================================ #
