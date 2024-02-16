extends Node2D


var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _ball: RigidBody2D = $Ball
@onready var _title_sprite_animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $Walls/TopWall.connect("body_entered", _on_top_wall_body_entered)
    $Walls/LeftWall.connect("body_entered", _on_left_wall_body_entered)
    $Walls/BottomWall.connect("body_entered", _on_bottom_wall_body_entered)
    $Walls/RightWall.connect("body_entered", _on_right_wall_body_entered)

    _title_sprite_animation_player\
            .connect("animation_finished", _on_animation_player_animation_finished)
    _reset_title_animation()

    var ball_speed = _rng.randf_range(160.0, 180.0)
    var ball_velocity = Vector2.UP * ball_speed
    ball_velocity = ball_velocity.rotated(_rng.randf_range(0.0, 2.0 * PI))
    _ball.set_linear_velocity(ball_velocity)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

#region Listens to Walls/*.body_entered(body: Node)
func _on_top_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_top")


func _on_left_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_left")


func _on_bottom_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_bottom")


func _on_right_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_right")
#endregion


## Listens to $Sprite2D/AnimationPlayer.animation_finished(anim_name:StringName)
func _on_animation_player_animation_finished(anim_name:StringName) -> void:
    if anim_name != "idle":
        _reset_title_animation()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _reset_title_animation() -> void:
    _title_sprite_animation_player.play("idle")
#endregion
# ============================================================================ #
