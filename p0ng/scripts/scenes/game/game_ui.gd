extends UI


var game_paused: bool


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $PauseMenuContainer/ResumeButton\
            .connect("pressed", _on_resume_request)
    $PauseMenuContainer/QuitToDesktopButton\
            .connect("pressed", _on_pause_menu_quit_to_desktop_button_pressed)

    game_paused = false


func _process(_delta: float) -> void:
    if Input.is_action_just_released("pause") and not game_paused:
        tween_transition_slide_container($PauseMenuContainer, Vector2.UP, TRANS_DURATION)
        game_paused = true
    elif Input.is_action_just_released("pause") and game_paused:
        _on_resume_request()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $PauseMenuContainer/ResumeButton.pressed()
func _on_resume_request() -> void:
    $PauseMenuContainer.get_children()
    tween_transition_slide_container($PauseMenuContainer, Vector2.DOWN, TRANS_DURATION)
    game_paused = false

## Listens to $PauseMenuContainer/QuitToDesktopButton.pressed()
func _on_pause_menu_quit_to_desktop_button_pressed() -> void:
    get_tree().quit()

#endregion
# ============================================================================ #
