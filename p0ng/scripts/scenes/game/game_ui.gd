extends UI


var paused: bool


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $PauseMenuContainer/ResumeButton\
            .connect("pressed", _on_resume_request)
    $PauseMenuContainer/QuitToDesktopButton\
            .connect("pressed", _on_pause_menu_quit_to_desktop_button_pressed)

    paused = false


func _process(_delta: float) -> void:
    if Input.is_action_just_released("pause") and not paused:
        print_debug("Pause Request")
        slide_transition($PauseMenuContainer, Vector2.UP, 0.5)
        paused = true
    elif Input.is_action_just_released("pause") and paused:
        print_debug("Resume Request")
        _on_resume_request()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $PauseMenuContainer/ResumeButton.pressed()
func _on_resume_request() -> void:
    slide_transition($PauseMenuContainer, Vector2.DOWN, 0.5)
    paused = false

## Listens to $PauseMenuContainer/QuitToDesktopButton.pressed()
func _on_pause_menu_quit_to_desktop_button_pressed() -> void:
    get_tree().quit()

#endregion
# ============================================================================ #