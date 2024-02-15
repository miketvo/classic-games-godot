extends GameScene2D


var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var _ball: RigidBody2D = $Ball
@onready var _title_sprite_animation_player: AnimationPlayer = $Title/Sprite2D/AnimationPlayer


# ============================================================================ #
#region Scene setup
func _ready() -> void:
    _reset_title()

    var ball_speed = _rng.randf_range(160.0, 180.0)
    var ball_velocity = Vector2.UP * ball_speed
    ball_velocity = ball_velocity.rotated(_rng.randf_range(0.0, 2.0 * PI))
    _ball.set_linear_velocity(ball_velocity)

    if OS.is_debug_build():
        print_debug("Scene initialized.")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

#region Listens to Title/Walls/*.body_entered(body: Node)
func _on_top_wall_body_entered(body: Node):
    if body == _ball:
        _title_sprite_animation_player.play("collide_top")


func _on_left_wall_body_entered(body: Node):
    if body == _ball:
        _title_sprite_animation_player.play("collide_left")


func _on_bottom_wall_body_entered(body: Node):
    if body == _ball:
        _title_sprite_animation_player.play("collide_bottom")


func _on_right_wall_body_entered(body: Node):
    if body == _ball:
        _title_sprite_animation_player.play("collide_right")
#endregion


#region Listens to Title/Sprite2D/AnimationPlayer.animation_finished(anim_name:StringName)
func _on_animation_player_animation_finished(anim_name:StringName) -> void:
    if anim_name != "idle":
        _reset_title()
#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _reset_title():
    _title_sprite_animation_player.play("idle")
#endregion
# ============================================================================ #
