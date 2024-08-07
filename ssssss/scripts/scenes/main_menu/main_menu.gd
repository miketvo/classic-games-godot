extends GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $UI/MainMenuUI.connect("acted", _on_main_menu_ui_acted)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $UIContainer/MainMenuUI.acted(action: StringName).
func _on_main_menu_ui_acted(action: StringName) -> void:
    match action:
        "start_mode_1":
            pass  # TODO: Change to your game scene here.
        "start_mode_2":
            pass  # TODO: Change to your game scene here.
        "settings":
            scene_finished.emit(SceneKey.SETTINGS_MENU)

#endregion
# ============================================================================ #
