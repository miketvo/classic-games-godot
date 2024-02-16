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
    _slide_transition($MainMenuContainer, Vector2.LEFT, Global.UI_TRANS_DURATION)
    _slide_transition($StartMenuContainer, Vector2.LEFT, Global.UI_TRANS_DURATION)


## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_quit_button_pressed() -> void:
    get_tree().quit()


## Listens to $StartMenuContainer/BackButton.pressed()
func _on_start_menu_back_button_pressed() -> void:
    _slide_transition($MainMenuContainer, Vector2.RIGHT, Global.UI_TRANS_DURATION)
    _slide_transition($StartMenuContainer, Vector2.RIGHT, Global.UI_TRANS_DURATION)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _slide_transition(
        ui_element: Control,
        direction_vector: Vector2,
        duration: float
) -> void:
    if direction_vector not in Global.UNIT_VECTORS:
        assert(
                false,
                "MainMenuUI._slide_transition() "
                + "only accepts unit vector for `direction_vector`"
        )

    var tween = create_tween()
    tween.tween_property(
            ui_element, "position",
            direction_vector * (
                    get_viewport_rect().size.x / 2
                    + ui_element.size.x * ui_element.scale.x / 2
            ),
            duration
    ).as_relative().from_current().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
#endregion
# ============================================================================ #
