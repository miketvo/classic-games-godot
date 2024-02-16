extends Control


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $MainMenuContainer/StartButton.connect("pressed", _on_main_menu_start_button_pressed)
    $MainMenuContainer/QuitButton.connect("pressed", _on_main_menu_quit_button_pressed)

    $StartMenuContainer/BackButton.connect("pressed", _on_start_menu_back_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_start_button_pressed() -> void:
    UI.slide_transition($MainMenuContainer, Vector2.LEFT, UI.TRANS_DURATION)
    UI.slide_transition($StartMenuContainer, Vector2.LEFT, UI.TRANS_DURATION)


## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_quit_button_pressed() -> void:
    get_tree().quit()


## Listens to $StartMenuContainer/BackButton.pressed()
func _on_start_menu_back_button_pressed() -> void:
    UI.slide_transition($MainMenuContainer, Vector2.RIGHT, UI.TRANS_DURATION)
    UI.slide_transition($StartMenuContainer, Vector2.RIGHT, UI.TRANS_DURATION)

#endregion
# ============================================================================ #
