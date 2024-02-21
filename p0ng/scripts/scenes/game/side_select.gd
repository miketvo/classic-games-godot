extends GameScene2D


@onready var _left_paddle: AnimatableBody2D = $Background/Spawns/LeftPaddleSpawn/Paddle
@onready var _right_paddle: AnimatableBody2D = $Background/Spawns/RightPaddleSpawn/Paddle
@onready var _ui_left_button: Button =\
        $UI/SideSelectContainer/HBoxContainer/LeftButtonContainer/LeftButton
@onready var _ui_right_button: Button =\
        $UI/SideSelectContainer/HBoxContainer/RightButtonContainer/RightButton


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _ui_left_button.connect("mouse_entered", _on_focused_left_side)
    _ui_left_button.connect("focus_entered", _on_focused_left_side)
    _ui_left_button.connect("pressed", _on_selected_left_side)
    _ui_right_button.connect("mouse_entered", _on_focused_right_side)
    _ui_right_button.connect("focus_entered", _on_focused_right_side)
    _ui_right_button.connect("pressed", _on_selected_right_side)
    _ui_left_button.grab_focus()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to _ui_left_button.focus_entered().
func _on_focused_left_side() -> void:
    _ui_left_button.grab_focus()
    _left_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
    _right_paddle.get_node("Sprite2D/AnimationPlayer").play("idle")


## Listens to _ui_left_button.pressed().
func _on_selected_left_side() -> void:
    Global.game_mode = Global.GameMode.GAME_MODE_ONE_PLAYER_LEFT
    scene_finished.emit(SceneKey.GAME)


## Listens to _ui_right_button.pressed().
func _on_focused_right_side() -> void:
    _ui_right_button.grab_focus()
    _right_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
    _left_paddle.get_node("Sprite2D/AnimationPlayer").play("idle")


## Listens to _ui_right_button.focus_entered().
func _on_selected_right_side() -> void:
    Global.game_mode = Global.GameMode.GAME_MODE_ONE_PLAYER_RIGHT
    scene_finished.emit(SceneKey.GAME)

#endregion
# ============================================================================ #
