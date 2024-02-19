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

    var ball_speed = _rng.randf_range(160.0, 180.0)
    var ball_velocity = Vector2.RIGHT * ball_speed
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
        _title_sprite_animation_player.queue("idle")


func _on_left_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_left")
        _title_sprite_animation_player.queue("idle")


func _on_bottom_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_bottom")
        _title_sprite_animation_player.queue("idle")


func _on_right_wall_body_entered(body: Node) -> void:
    if body == _ball:
        _title_sprite_animation_player.play("collide_right")
        _title_sprite_animation_player.queue("idle")
#endregion

#endregion
# ============================================================================ #
