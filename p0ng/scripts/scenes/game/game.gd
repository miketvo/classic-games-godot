extends GameScene2D


const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Paddle: PackedScene = preload("res://scenes/game/paddle.tscn")
const PlayerPaddleScript: Script = preload("res://scripts/characters/player_paddle.gd")

var ball: RigidBody2D
var left_paddle: AnimatableBody2D
var right_paddle: AnimatableBody2D
var left_score: int
var right_score: int
var game_round: int

var _rng = RandomNumberGenerator.new()
var _ball_prior_velocity: Vector2
var _ball_active: bool
var _side_served: int

@onready var _ball_spawn: Node2D = $Spawns/BallSpawn
@onready var _left_paddle_spawn: Node2D = $Spawns/LeftPaddleSpawn
@onready var _right_paddle_spawn: Node2D = $Spawns/RightPaddleSpawn
@onready var _score_label: Dictionary = {
    Global.SIDE_LEFT: $UI/GameUI/HUDContainer/LeftScore,
    Global.SIDE_RIGHT: $UI/GameUI/HUDContainer/RightScore,
}


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _spawn_left_paddle()
    _spawn_right_paddle()
    _configure_world()
    _configure_ui()
    _configure_game()


func _process(_delta: float) -> void:
    _score_label[Global.SIDE_LEFT].text = "%d" % left_score
    _score_label[Global.SIDE_RIGHT].text = "%d" % right_score


func _physics_process(delta: float) -> void:
    if not _ball_active:
        _spawn_ball()
        _serve_ball(
                delta,
                Global.BALL_SPEED_INITIAL,
                _side_served,
                Global.SERVING_ANGULAR_VARIATION
        )
        _ball_active = true
        game_round += 1
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to ball.body_entered(body: Node)
func _on_ball_body_entered(body: Node) -> void:
    var top_bound = $World/TopBound
    var bottom_bound = $World/BottomBound

    match body:
        top_bound:
            top_bound.get_node("Sprite2D/AnimationPlayer").play("active")
        bottom_bound:
            bottom_bound.get_node("Sprite2D/AnimationPlayer").play("active")
        left_paddle, right_paddle:
            _ball_prior_velocity = ball.linear_velocity
            match body:
                left_paddle:
                    left_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
                right_paddle:
                    right_paddle.get_node("Sprite2D/AnimationPlayer").play("active")


## Listens to ball.body_entered(body: Node)
func _on_ball_body_exited(body: Node) -> void:
    if body in [ left_paddle, right_paddle ]:
        var boosted_velocity: Vector2 =\
                Vector2.from_angle(ball.linear_velocity.angle())\
                * _ball_prior_velocity.length()\
                * Global.BALL_SPEED_DIFFICULTY_MULTIPLIER
        ball.linear_velocity = boosted_velocity


## Listens to $World/VerticalSeparator.body_entered(body: Node)
func _on_vertical_separator_body_entered(body: Node) -> void:
    if body == ball:
        $World/VerticalSeparator/Sprite2D/AnimationPlayer.play("active")


## Listens to $World/VerticalSeparator.body_entered(body: Node)
func _on_left_bound_body_entered(body: Node) -> void:
    if body == ball:
        _win_round(Global.SIDE_RIGHT)


## Listens to $World/VerticalSeparator.body_entered(body: Node)
func _on_right_bound_body_entered(body: Node) -> void:
    if body == ball:
        _win_round(Global.SIDE_LEFT)


# Listens to $*/Sprite2D/AnimationPlayer.animation_finished(anim_name: StringName)
#region
func _on_top_bound_animation_finished(anim_name: StringName) -> void:
    if anim_name != "idle":
        $World/TopBound/Sprite2D/AnimationPlayer.play("idle")


func _on_bottom_bound_animation_finished(anim_name: StringName) -> void:
    if anim_name != "idle":
        $World/BottomBound/Sprite2D/AnimationPlayer.play("idle")


func _on_vertical_separator_animation_finished(anim_name: StringName) -> void:
    if anim_name != "idle":
        $World/VerticalSeparator/Sprite2D/AnimationPlayer.play("idle")


func _on_left_paddle_animation_finished(anim_name: StringName) -> void:
    if anim_name != "idle":
        left_paddle.get_node("Sprite2D/AnimationPlayer").play("idle")


func _on_right_paddle_animation_finished(anim_name: StringName) -> void:
    if anim_name != "idle":
        right_paddle.get_node("Sprite2D/AnimationPlayer").play("idle")
#endregion


## Listens to $UI/GameUI/PauseMenuContainer/RestartButton.pressed()
func _on_restart_request() -> void:
    scene_finished.emit(SceneKey.GAME)


## Listens to $UI/GameUI/PauseMenuContainer/EndGameButton.pressed()
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
    left_paddle.rotation = PI
    left_paddle.player_id = PlayerPaddle.PLAYER_LEFT
    left_paddle.get_node("Sprite2D/AnimationPlayer")\
            .connect("animation_finished", _on_left_paddle_animation_finished)
    add_child(left_paddle)


func _spawn_right_paddle() -> void:
    right_paddle = Paddle.instantiate()
    right_paddle.set_script(PlayerPaddleScript)
    right_paddle.position = _right_paddle_spawn.position
    right_paddle.player_id = PlayerPaddle.PLAYER_RIGHT
    right_paddle.get_node("Sprite2D/AnimationPlayer")\
            .connect("animation_finished", _on_right_paddle_animation_finished)
    add_child(right_paddle)


func _spawn_ball() -> void:
    ball = Ball.instantiate()
    ball.position = _ball_spawn.position
    ball.connect("body_entered", _on_ball_body_entered)
    ball.connect("body_exited", _on_ball_body_exited)
    _ball_active = false
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
    $World/TopBound/Sprite2D/AnimationPlayer.connect(
            "animation_finished",
            _on_top_bound_animation_finished
    )
    $World/BottomBound/Sprite2D/AnimationPlayer.connect(
            "animation_finished",
            _on_bottom_bound_animation_finished
    )
    $World/VerticalSeparator.connect(
            "body_entered",
            _on_vertical_separator_body_entered
    )
    $World/VerticalSeparator/Sprite2D/AnimationPlayer.connect(
            "animation_finished",
            _on_vertical_separator_animation_finished
    )
    $World/LeftBound.connect(
            "body_entered",
            _on_left_bound_body_entered
    )
    $World/RightBound.connect(
            "body_entered",
            _on_right_bound_body_entered
    )


func _configure_ui() -> void:
    $UI/GameUI/PauseMenuContainer/VBoxContainer/RestartButton\
            .connect("pressed", _on_restart_request)
    $UI/GameUI/PauseMenuContainer/VBoxContainer/EndGameButton\
            .connect("pressed", _on_end_game_request)


func _configure_game() -> void:
    game_round = 0
    left_score = 0
    right_score = 0
    _side_served = Global.FIRST_SIDE_SERVED


func _win_round(winning_side: int) -> void:
    match winning_side:
        Global.SIDE_LEFT:
            left_score += 1
        Global.SIDE_RIGHT:
            right_score += 1
        _:
            assert(false, "Unrecognized side")

    match _side_served:
        Global.SIDE_LEFT:
            _side_served = Global.SIDE_RIGHT
        Global.SIDE_RIGHT:
            _side_served = Global.SIDE_LEFT

    _despawn_ball()
    _ball_active = false
# ============================================================================ #
