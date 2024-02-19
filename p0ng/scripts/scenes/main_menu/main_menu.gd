extends GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $UI/MainMenuUI/MainMenuContainer/StartButton.grab_focus()
    $UI/MainMenuUI/StartMenuContainer/OnePlayerButton\
            .connect("pressed", _on_main_menu_ui_start_menu_one_player_button_pressed)
    $UI/MainMenuUI/StartMenuContainer/TwoPlayersButton\
            .connect("pressed", _on_main_menu_ui_start_menu_two_players_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $UIContainer/MainMenuUI/StartMenuContainer/OnePlayer.pressed().
func _on_main_menu_ui_start_menu_one_player_button_pressed() -> void:
    assert(false, "Not implemented")

## Listens to $UIContainer/MainMenuUI/StartMenuContainer/TwoPlayers.pressed().
func _on_main_menu_ui_start_menu_two_players_button_pressed() -> void:
    scene_finished.emit(SceneKey.GAME)

#endregion
# ============================================================================ #
