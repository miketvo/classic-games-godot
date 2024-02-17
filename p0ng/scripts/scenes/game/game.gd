extends GameScene2D


const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Paddle: PackedScene = preload("res://scenes/game/paddle.tscn")
const PlayerPaddleScript: Script = preload("res://scripts/characters/player_paddle.gd")

var ball: RigidBody2D
var left_paddle: AnimatableBody2D
var right_paddle: AnimatableBody2D
var left_score: int
var right_score: int

var _rng = RandomNumberGenerator.new()
var _ball_active: bool
var _round: int

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
    _spawn_ball()
    _configure_world()
    _configure_ui()
    _configure_game()


func _process(_delta: float) -> void:
    _score_label[Global.SIDE_LEFT].text = "%d" % left_score
    _score_label[Global.SIDE_RIGHT].text = "%d" % right_score


func _physics_process(delta: float) -> void:
    if not _ball_active and _round == 0:
        _serve_ball(
                delta,
                Global.BALL_SPEED_INITIAL,
                Global.FIRST_SIDE_SERVED,
                Global.SERVING_ANGULAR_VARIATION
        )
        _ball_active = true
        _round = 1
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
            match body:
                left_paddle:
                    left_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
                right_paddle:
                    right_paddle.get_node("Sprite2D/AnimationPlayer").play("active")


## Listens to $World/VerticalSeparator.body_entered(body: Node)
func _on_vertical_separator_body_entered(body: Node) -> void:
    if body == ball:
        $World/VerticalSeparator/Sprite2D/AnimationPlayer.play("active")


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
    _ball_active = false
    ball.connect("body_entered", _on_ball_body_entered)
    add_child(ball)


## Serve the ball to the side of the game defined in [param direction], taking
## [param delta] into account.
func _serve_ball(
        delta: float,
        delta_speed: float,
        direction: int,
        angular_variation: PackedFloat32Array = [0.0, 0.0]
) -> void:
    var base_vector: Vector2 = Vector2.LEFT if direction == Global.SIDE_LEFT\
            else Vector2.RIGHT
    base_vector = base_vector.rotated(_rng.randf_range(
            angular_variation[0],
            angular_variation[1]
    ))

    # a = delta(speed) / delta(time) (px/s^2)
    var acceleration: float = delta_speed / (delta * Engine.physics_ticks_per_second)
    var impulse = base_vector * ball.mass * acceleration # F = m * a (Newton)

    ball.apply_central_impulse(impulse)
#endregion


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


func _configure_ui() -> void:
    $UI/GameUI/PauseMenuContainer/VBoxContainer/RestartButton\
            .connect("pressed", _on_restart_request)
    $UI/GameUI/PauseMenuContainer/VBoxContainer/EndGameButton\
            .connect("pressed", _on_end_game_request)


func _configure_game():
    _round = 0
    left_score = 0
    right_score = 0
# ============================================================================ #
