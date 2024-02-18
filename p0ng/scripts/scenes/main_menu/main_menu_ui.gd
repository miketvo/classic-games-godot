extends UI


var input_disabled: bool


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    input_disabled = false

    $MainMenuContainer/StartButton.connect("pressed", _on_main_menu_start_button_pressed)
    $MainMenuContainer/QuitButton.connect("pressed", _on_main_menu_quit_button_pressed)

    $StartMenuContainer/BackButton.connect("pressed", _on_start_menu_back_button_pressed)


func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_start_button_pressed() -> void:
    input_disabled = true
    $StartMenuContainer/BackButton.grab_focus()
    tween_transition_slide_container($MainMenuContainer, Vector2.LEFT, TRANS_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($StartMenuContainer, Vector2.LEFT, TRANS_DURATION)\
            .connect("finished", _on_tween_transition_finshed)


## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_quit_button_pressed() -> void:
    get_tree().quit()


## Listens to $StartMenuContainer/BackButton.pressed()
func _on_start_menu_back_button_pressed() -> void:
    input_disabled = true
    $MainMenuContainer/StartButton.grab_focus()
    tween_transition_slide_container($MainMenuContainer, Vector2.RIGHT, TRANS_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($StartMenuContainer, Vector2.RIGHT, TRANS_DURATION)\
            .connect("finished", _on_tween_transition_finshed)


## Listens to tween transition Tween.finished() to re-enable input
func _on_tween_transition_finshed() -> void:
    input_disabled = false

#endregion
# ============================================================================ #
