extends GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $UI/MainMenuUI.connect("button_pressed", _on_main_menu_ui_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $UIContainer/MainMenuUI.button_pressed(action: StringName).
func _on_main_menu_ui_button_pressed(action: StringName) -> void:
    match action:
        "start_one_player":
            scene_finished.emit(SceneKey.SIDE_SELECT)
        "start_two_players":
            Global.current_game_mode = Global.GameMode.GAME_MODE_TWO_PLAYERS
            scene_finished.emit(SceneKey.GAME)

#endregion
# ============================================================================ #
