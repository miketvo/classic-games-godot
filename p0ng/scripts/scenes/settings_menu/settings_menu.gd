extends GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $UI/SettingsMenuUI.connect("button_pressed", _on_main_menu_ui_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $UIContainer/MainMenuUI.button_pressed(action: StringName).
func _on_main_menu_ui_button_pressed(action: StringName) -> void:
    match action:
        "back_to_main_menu":
            scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #
