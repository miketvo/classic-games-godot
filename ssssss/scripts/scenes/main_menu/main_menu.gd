extends GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    %GameTitle/Sprite2D/AnimationPlayer.play("default")
    $UI/MainMenuUI.acted.connect(_on_main_menu_ui_acted)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $UIContainer/MainMenuUI.acted(action: StringName).
func _on_main_menu_ui_acted(action: StringName) -> void:
    match action:
        "start_classic_mode":
            Global.current_game_mode = Global.GameMode.CLASSIC
            scene_finished.emit(SceneKey.LEVEL_SELECT)
        "start_chaos_mode":
            Global.current_game_mode = Global.GameMode.CHAOS
            scene_finished.emit(SceneKey.LEVEL_SELECT)
        "settings":
            scene_finished.emit(SceneKey.SETTINGS_MENU)

#endregion
# ============================================================================ #
