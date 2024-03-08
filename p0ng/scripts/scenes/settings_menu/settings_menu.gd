extends GameScene2D


@onready var _ui: UI = $UI/SettingsMenuUI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _ui.connect("button_pressed", _on_main_menu_ui_button_pressed)
    _load_config()


func _process(_delta: float) -> void:
    pass
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


# ============================================================================ #
#region Utils
func _load_config() -> void:
    var ui_graphics = _ui.get_node("Graphics")
    for resolution_name in GameConfig.RESOLUTIONS.keys():
        var resolution_option_button: OptionButton =\
                ui_graphics.get_node("Resolution/OptionButton")
        resolution_option_button.add_item(resolution_name)
        if resolution_name == GameConfig.config.graphics.resolution:
            resolution_option_button.select(resolution_option_button.item_count - 1)
    ui_graphics.get_node("Fullscreen/ToggleButton").button_pressed =\
            GameConfig.config.graphics.fullscreen
    ui_graphics.get_node("PostProcessing/ToggleButton").button_pressed =\
            GameConfig.config.graphics.post_processing
    ui_graphics.get_node("CrtEffect/ToggleButton").button_pressed =\
            GameConfig.config.graphics.crt_effect

    var ui_sounds = _ui.get_node("Sounds")
    ui_sounds.get_node("MasterVolume/HSlider").set_value_no_signal(
            GameConfig.config.sounds.master_volume
    )
    ui_sounds.get_node("MasterVolume/MuteToggleButton").button_pressed =\
            GameConfig.config.sounds.master_muted
    ui_sounds.get_node("UIVolume/HSlider").set_value_no_signal(
            GameConfig.config.sounds.ui_volume
    )
    ui_sounds.get_node("UIVolume/MuteToggleButton").button_pressed =\
            GameConfig.config.sounds.ui_muted
    ui_sounds.get_node("GameplayVolume/HSlider").set_value_no_signal(
            GameConfig.config.sounds.gameplay_volume
    )
    ui_sounds.get_node("GameplayVolume/MuteToggleButton").button_pressed =\
            GameConfig.config.sounds.gameplay_muted
#endregion
# ============================================================================ #
