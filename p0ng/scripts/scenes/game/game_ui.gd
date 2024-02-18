extends UI


var input_disabled: bool
var disable_pausing: bool


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    input_disabled = false
    disable_pausing = false
    process_mode = Node.PROCESS_MODE_ALWAYS

    $PauseMenuContainer/VBoxContainer/ResumeButton\
            .connect("pressed", _on_resume_request)
    $PauseMenuContainer/VBoxContainer/QuitToDesktopButton\
            .connect("pressed", _on_menu_quit_to_desktop_request)

    $EndGameDialogContainer/MenuContainer/VBoxContainer/QuitToDesktopButton\
            .connect("pressed", _on_menu_quit_to_desktop_request)


func _process(_delta: float) -> void:
    if not input_disabled and not disable_pausing:
        if Input.is_action_just_released("pause") and not get_tree().paused:
            input_disabled = true
            get_tree().paused = true
            tween_transition_slide_container($PauseMenuContainer, Vector2.UP, TRANS_DURATION)\
                    .set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)\
                    .connect("finished", _on_tween_transition_finshed)
        elif Input.is_action_just_released("pause") and get_tree().paused:
            _on_resume_request()


func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $PauseMenuContainer/ResumeButton.pressed()
func _on_resume_request() -> void:
    for control: Control in $PauseMenuContainer/VBoxContainer.get_children():
        control.release_focus()

    input_disabled = true
    get_tree().paused = false
    tween_transition_slide_container($PauseMenuContainer, Vector2.DOWN, TRANS_DURATION)\
            .set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)\
            .connect("finished", _on_tween_transition_finshed)

## Listens to $PauseMenuContainer/QuitToDesktopButton.pressed() and
## $EndGameDialogContainer/MenuContainer/VBoxContainer/QuitToDesktopButton.pressed()
func _on_menu_quit_to_desktop_request() -> void:
    get_tree().quit()


## Listens to tween transition Tween.finished() to re-enable input
func _on_tween_transition_finshed() -> void:
    input_disabled = false

#endregion
# ============================================================================ #
