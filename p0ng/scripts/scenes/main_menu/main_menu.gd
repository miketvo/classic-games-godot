extends GameScene2D


@onready var _main_menu_ui: Control = $UIContainer/MainMenuUI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _main_menu_ui.get_node("StartMenuContainer/OnePlayerButton")\
            .connect("pressed", _on_main_menu_ui_start_menu_one_player_button_pressed)
    _main_menu_ui.get_node("StartMenuContainer/TwoPlayersButton")\
            .connect("pressed", _on_main_menu_ui_start_menu_two_players_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to UIContainer/MainMenuUI/StartMenuContainer/OnePlayer.pressed()
func _on_main_menu_ui_start_menu_one_player_button_pressed():
    scene_finished.emit(SceneKey.GAME)

## Listens to UIContainer/MainMenuUI/StartMenuContainer/TwoPlayers.pressed()
func _on_main_menu_ui_start_menu_two_players_button_pressed():
    scene_finished.emit(SceneKey.GAME)

#endregion
# ============================================================================ #
