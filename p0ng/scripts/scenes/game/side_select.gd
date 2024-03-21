extends GameScene2D


@onready var _left_paddle: Node2D = $Background/Spawns/LeftPaddleSpawn/Paddle
@onready var _right_paddle: Node2D = $Background/Spawns/RightPaddleSpawn/Paddle
@onready var _ui_left_button: Button = %LeftButton
@onready var _ui_right_button: Button = %RightButton
@onready var _ui_back_button: Button = %BackButton


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _ui_back_button.connect("pressed", _on_back_button_pressed)
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

# Listens to _ui_back_button.pressed().
func _on_back_button_pressed() -> void:
    scene_finished.emit(SceneKey.MAIN_MENU)


# Listens to _ui_left_button.focus_entered().
func _on_focused_left_side() -> void:
    _ui_left_button.grab_focus()
    _left_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
    _right_paddle.get_node("Sprite2D/AnimationPlayer").play("idle")


# Listens to _ui_left_button.pressed().
func _on_selected_left_side() -> void:
    Global.current_game_mode = Global.GameMode.GAME_MODE_ONE_PLAYER_LEFT
    scene_finished.emit(SceneKey.GAME)


# Listens to _ui_right_button.pressed().
func _on_focused_right_side() -> void:
    _ui_right_button.grab_focus()
    _right_paddle.get_node("Sprite2D/AnimationPlayer").play("active")
    _left_paddle.get_node("Sprite2D/AnimationPlayer").play("idle")


# Listens to _ui_right_button.focus_entered().
func _on_selected_right_side() -> void:
    Global.current_game_mode = Global.GameMode.GAME_MODE_ONE_PLAYER_RIGHT
    scene_finished.emit(SceneKey.GAME)

#endregion
# ============================================================================ #
