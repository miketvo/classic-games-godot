extends UI


@export var game_point_text: String

var input_disabled: bool
var disable_pausing: bool

@onready var _score_label: Dictionary = {
    Global.SIDE_LEFT: $HUDContainer/LeftScore,
    Global.SIDE_RIGHT: $HUDContainer/RightScore,
}
@onready var _pause_menu: Container = $PauseMenuContainer
@onready var _endgame_dialog: Container = $EndGameDialogContainer
@onready var _win_label: Dictionary = {
    Global.SIDE_LEFT: $EndGameDialogContainer/MessageContainer/LeftContainer/WinLabel,
    Global.SIDE_RIGHT: $EndGameDialogContainer/MessageContainer/RightContainer/WinLabel,
}
@onready var _lose_label: Dictionary = {
    Global.SIDE_LEFT: $EndGameDialogContainer/MessageContainer/LeftContainer/LoseLabel,
    Global.SIDE_RIGHT: $EndGameDialogContainer/MessageContainer/RightContainer/LoseLabel,
}


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    Global.software_cursor_visibility = SoftwareCursor.Visibility.IDLE_AUTO_HIDE

    input_disabled = false
    disable_pausing = false
    process_mode = Node.PROCESS_MODE_ALWAYS

    _pause_menu.get_node("VBoxContainer/ResumeButton")\
            .connect("pressed", _on_resume_request)
    _pause_menu.get_node("VBoxContainer/QuitToDesktopButton")\
            .connect("pressed", _on_quit_to_desktop_request)
    _pause_menu.get_node("VBoxContainer/RestartButton")\
            .connect("pressed", _on_restart_request)
    _pause_menu.get_node("VBoxContainer/EndGameButton")\
            .connect("pressed", _on_end_game_request)
    _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton")\
            .connect("pressed", _on_restart_request)
    _endgame_dialog.get_node("MenuContainer/VBoxContainer/BackToMainMenuButton")\
            .connect("pressed", _on_end_game_request)
    _endgame_dialog.get_node("MenuContainer/VBoxContainer/QuitToDesktopButton")\
            .connect("pressed", _on_quit_to_desktop_request)

    _endgame_dialog.process_mode = Node.PROCESS_MODE_DISABLED
    _endgame_dialog.modulate = Color(1.0, 1.0, 1.0, 0.0)
    _win_label[Global.SIDE_LEFT].hide()
    _win_label[Global.SIDE_RIGHT].hide()
    _lose_label[Global.SIDE_LEFT].hide()
    _lose_label[Global.SIDE_RIGHT].hide()


func _process(_delta: float) -> void:
    if not input_disabled and not disable_pausing:
        if Input.is_action_just_released("pause") and not get_tree().paused:
            Global.software_cursor_visibility = SoftwareCursor.Visibility.ALWAYS_VISIBLE
            input_disabled = true
            get_tree().paused = true
            _pause_menu.get_node("VBoxContainer/ResumeButton").grab_focus()
            tween_transition_slide_container(
                    $PauseMenuContainer,
                    Vector2.UP,
                    UI_TRANSITION_DURATION
            ).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)\
                    .connect("finished", _on_tween_transition_finshed)
        elif Input.is_action_just_released("pause") and get_tree().paused:
            _on_resume_request()


func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs.
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func update_score_labels(left_score: int, right_score: int, game_point_state) -> void:
    var left_score_label_text: String = "%s%d" %\
            [ game_point_text + " " if not game_point_state ^ 0b10 else "", left_score ]
    _score_label[Global.SIDE_LEFT].text = left_score_label_text
    var right_score_label_text: String = "%d%s" %\
            [ right_score, " " + game_point_text if not game_point_state ^ 0b01 else "" ]
    _score_label[Global.SIDE_RIGHT].text = right_score_label_text


func game_over(winning_side: int) -> void:
    Global.software_cursor_visibility = SoftwareCursor.Visibility.ALWAYS_VISIBLE

    match winning_side:
        Global.SIDE_LEFT:
            _win_label[Global.SIDE_LEFT].show()
            _lose_label[Global.SIDE_RIGHT].show()
        Global.SIDE_RIGHT:
            _win_label[Global.SIDE_RIGHT].show()
            _lose_label[Global.SIDE_LEFT].show()
        _:
            assert(false, "Unrecognized side")

    _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton").grab_focus()
    _endgame_dialog.process_mode = Node.PROCESS_MODE_INHERIT
    UI.tween_transition_fade_appear_container(
            _endgame_dialog,
            UI.UI_TRANSITION_DURATION / 4
    ).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    disable_pausing = true
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _pause_menu.get_node("ResumeButton.pressed().
func _on_resume_request() -> void:
    Global.software_cursor_visibility = SoftwareCursor.Visibility.IDLE_AUTO_HIDE
    for control: Control in _pause_menu.get_node("VBoxContainer").get_children():
        control.release_focus()

    input_disabled = true
    get_tree().paused = false
    tween_transition_slide_container($PauseMenuContainer, Vector2.DOWN, UI_TRANSITION_DURATION)\
            .set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)\
            .connect("finished", _on_tween_transition_finshed)

# Listens to _pause_menu.get_node("QuitToDesktopButton.pressed() and
## $EndGameDialogContainer/MenuContainer/VBoxContainer/QuitToDesktopButton.pressed().
func _on_quit_to_desktop_request() -> void:
    get_tree().quit()


# Listens to _pause_menu.get_node("RestartButton.pressed() and
## _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton").pressed().
func _on_restart_request() -> void:
    get_tree().paused = false
    button_pressed.emit("restart")


# Listens to _pause_menu.get_node("EndGameButton.pressed() and
## _endgame_dialog.get_node("MenuContainer/VBoxContainer/BackToMainMenuButton").pressed().
func _on_end_game_request() -> void:
    get_tree().paused = false
    button_pressed.emit("end_game")


# Listens to tween transition Tween.finished() to re-enable input.
func _on_tween_transition_finshed() -> void:
    input_disabled = false

#endregion
# ============================================================================ #
