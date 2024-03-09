extends GameScene2D


@onready var _ui: UI = $UI/SettingsMenuUI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _ui.connect("acted", _on_main_menu_ui_acted)
    _ui.connect("acted_with_data", _on_main_menu_ui_acted_with_data)
    _load_config()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $UIContainer/MainMenuUI.acted(action: StringName).
func _on_main_menu_ui_acted(action: StringName) -> void:
    match action:
        "back_to_main_menu":
            scene_finished.emit(SceneKey.MAIN_MENU)


# Listens to $UIContainer/MainMenuUI.acted_with_data(action: StringName, data: Variant).
func _on_main_menu_ui_acted_with_data(action: StringName, data: Variant) -> void:
    match action:
        "graphics_resolution_selected":
            var resolution: String = String(data)
            GameConfig.config.graphics.resolution = resolution
        "graphics_fullscreen_toggled":
            var toggled_on: bool = data
            GameConfig.config.graphics.fullscreen = toggled_on
        "graphics_post_processing_toggled":
            var toggled_on: bool = data
            GameConfig.config.graphics.post_processing = toggled_on
        "graphics_crt_effect_toggled":
            var toggled_on: bool = data
            GameConfig.config.graphics.crt_effect = toggled_on
        "sounds_master_volume_slider_updated":
            var new_value: float = data
            GameConfig.config.sounds.master_volume = new_value
        "sounds_master_volume_mute_toggled":
            var toggled_on: bool = data
            GameConfig.config.sounds.master_muted = toggled_on
        "sounds_ui_volume_slider_updated":
            var new_value: float = data
            GameConfig.config.sounds.ui_volume = new_value
        "sounds_ui_volume_mute_toggled":
            var toggled_on: bool = data
            GameConfig.config.sounds.ui_muted = toggled_on
        "sounds_gameplay_volume_slider_updated":
            var new_value: float = data
            GameConfig.config.sounds.gameplay_volume = new_value
        "sounds_gameplay_volume_mute_toggled":
            var toggled_on: bool = data
            GameConfig.config.sounds.gameplay_muted = toggled_on
        "save":
            var save_section: StringName = data
            GameConfig.save_config(save_section)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _load_config() -> void:
    var ui_graphics = _ui.get_node("Graphics")
    for resolution_key in GameConfig.RESOLUTIONS.keys():
        var current_resolution: Vector2i = Vector2i(get_viewport_rect().size)
        var resolution: Vector2i = GameConfig.RESOLUTIONS[resolution_key]
        var resolution_option_button: OptionButton =\
                ui_graphics.get_node("Resolution/OptionButton")

        resolution_option_button.add_item(resolution_key)
        var current_item_index: int = resolution_option_button.item_count - 1

        if resolution_key == GameConfig.config.graphics.resolution:
            resolution_option_button.select(current_item_index)
        if (
                resolution.x > current_resolution.x
                or resolution.y > current_resolution.y
        ):
            resolution_option_button.set_item_disabled(current_item_index, true)
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
