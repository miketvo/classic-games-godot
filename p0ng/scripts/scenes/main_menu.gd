extends GameScene2D


var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var _ball: RigidBody2D = $Ball
@onready var _title_sprite_animation_player: AnimationPlayer = $Title/Sprite2D/AnimationPlayer
@onready var _title_walls: Node2D = $Title/Walls
@onready var _main_menu_ui: Control = $UIContainer/MainMenuUI


# ============================================================================ #
#region Scene setup
func _ready() -> void:
    _setup_ui()
    _setup_title()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to UIContainer/MainMenuUI/StartButton.pressed()
func _on_main_menu_ui_start_button_pressed():
    scene_finished.emit(SceneKey.GAME)


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
        _reset_title_animation()
#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _setup_ui():
    _main_menu_ui.get_node("MainMenuContainer/StartButton")\
            .connect("pressed", _on_main_menu_ui_start_button_pressed)


func _setup_title():
    _title_walls.get_node("TopWall").connect("body_entered", _on_top_wall_body_entered)
    _title_walls.get_node("LeftWall").connect("body_entered", _on_left_wall_body_entered)
    _title_walls.get_node("BottomWall").connect("body_entered", _on_bottom_wall_body_entered)
    _title_walls.get_node("RightWall").connect("body_entered", _on_right_wall_body_entered)

    _title_sprite_animation_player\
            .connect("animation_finished", _on_animation_player_animation_finished)
    _reset_title_animation()

    var ball_speed = _rng.randf_range(160.0, 180.0)
    var ball_velocity = Vector2.UP * ball_speed
    ball_velocity = ball_velocity.rotated(_rng.randf_range(0.0, 2.0 * PI))
    _ball.set_linear_velocity(ball_velocity)


func _reset_title_animation():
    _title_sprite_animation_player.play("idle")
#endregion
# ============================================================================ #
