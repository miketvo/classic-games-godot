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
        "start_one_player":
            scene_finished.emit(SceneKey.SIDE_SELECT)
        "start_two_players":
            Global.current_game_mode = Global.GameMode.GAME_MODE_TWO_PLAYERS
            scene_finished.emit(SceneKey.GAME)
        "settings":
            scene_finished.emit(SceneKey.SETTINGS_MENU)

#endregion
# ============================================================================ #
