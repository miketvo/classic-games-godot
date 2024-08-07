extends UI


@export var game: GameScene2D

var _disable_pausing: bool

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

    _disable_pausing = false

    _pause_menu.get_node("VBoxContainer/ResumeButton")\
            .connect("pressed", _on_resume_request)
    if Global.os_platform in [ "Mobile", "Web" ]:
        UI.deactivate_control(_pause_menu.get_node(
                "VBoxContainer/QuitToDesktopButton"
        ))
    else:
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
    if Global.os_platform in [ "Mobile", "Web" ]:
        UI.deactivate_control(_endgame_dialog.get_node(
                "MenuContainer/VBoxContainer/QuitToDesktopButton"
        ))
    else:
        _endgame_dialog.get_node("MenuContainer/VBoxContainer/QuitToDesktopButton")\
            .connect("pressed", _on_quit_to_desktop_request)

    for child in get_tree().get_nodes_in_group("ui_container_slider_buttons"):
        assert(child is Button, "ui_container_slider_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_container_slider_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_scene_changer_buttons"):
        assert(child is Button, "ui_scene_changer_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_scene_changer_button_pressed)

    _endgame_dialog.modulate = Color(1.0, 1.0, 1.0, 0.0)
    _endgame_dialog.visible = false
    _win_label[Global.SIDE_LEFT].hide()
    _win_label[Global.SIDE_RIGHT].hide()
    _lose_label[Global.SIDE_LEFT].hide()
    _lose_label[Global.SIDE_RIGHT].hide()


func _process(_delta: float) -> void:
    if not input_disabled and not _disable_pausing:
        if Input.is_action_just_released("pause") and not game.is_paused():
            Global.software_cursor_visibility = SoftwareCursor.Visibility.ALWAYS_VISIBLE
            acted.emit("pause")
            input_disabled = true
            _pause_menu.get_node("VBoxContainer/ResumeButton").grab_focus()
            tween_transition_slide_container(
                    $PauseMenuContainer,
                    Vector2.UP,
                    UI_TRANSITION_DURATION
            ).connect("finished", _on_tween_transition_finshed)
        elif Input.is_action_just_released("pause") and game.is_paused():
            _on_resume_request()


func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs.
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func game_over(winning_side: int) -> void:
    _disable_pausing = true
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

    _endgame_dialog.visible = true
    _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton").grab_focus()
    tween_transition_fade_appear_container(
            _endgame_dialog,
            UI.UI_TRANSITION_DURATION / 8
    )
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _pause_menu.get_node("ResumeButton.pressed().
func _on_resume_request() -> void:
    Global.software_cursor_visibility = SoftwareCursor.Visibility.IDLE_AUTO_HIDE
    for control: Control in _pause_menu.get_node("VBoxContainer").get_children():
        control.release_focus()

    acted.emit("resume")
    input_disabled = true
    tween_transition_slide_container($PauseMenuContainer, Vector2.DOWN, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)

# Listens to _pause_menu.get_node("QuitToDesktopButton.pressed() and
## $EndGameDialogContainer/MenuContainer/VBoxContainer/QuitToDesktopButton.pressed().
func _on_quit_to_desktop_request() -> void:
    get_tree().quit()


# Listens to _pause_menu.get_node("RestartButton.pressed() and
## _endgame_dialog.get_node("MenuContainer/VBoxContainer/RestartButton").pressed().
func _on_restart_request() -> void:
    acted.emit("restart")


# Listens to _pause_menu.get_node("EndGameButton.pressed() and
## _endgame_dialog.get_node("MenuContainer/VBoxContainer/BackToMainMenuButton").pressed().
func _on_end_game_request() -> void:
    acted.emit("end_game")

#endregion
# ============================================================================ #
