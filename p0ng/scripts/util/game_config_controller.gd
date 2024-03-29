class_name GameConfigController
extends Node2D


const MIN_AUDIO_BUS_VOLUME_DB: float = -80.0
const MAX_AUDIO_BUS_VOLUME_DB: float = 0.0

@export var post_processing_node: WorldEnvironment
@export var crt_effect_node: ColorRect

var _master_bus_max_volume_db: float
var _ui_bus_max_volume_db: float
var _gameplay_bus_max_volume_db: float


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    # Set window size and center window for desktop devices.
    if Global.os_platform == "Desktop":
        # Workaround for:
        # https://github.com/godotengine/godot-proposals/issues/6247.
        # TODO: Reimplement this when there is better support for the above
        # issue in future Godot 4.x versions.
        var window: Window = get_window()
        window.size = GameConfig.RESOLUTIONS[GameConfig.config.graphics.resolution]
        @warning_ignore("integer_division")
        window.position = Vector2i(
                int(get_viewport_rect().size.x / 2) - window.size.x / 2,
                int(get_viewport_rect().size.y / 2) - window.size.y / 2
        )

    for bus_index in range(AudioServer.bus_count):
        match AudioServer.get_bus_name(bus_index):
            "Master":
                _master_bus_max_volume_db = AudioServer.get_bus_volume_db(bus_index)
            "UI":
                _ui_bus_max_volume_db = AudioServer.get_bus_volume_db(bus_index)
            "Gameplay":
                _gameplay_bus_max_volume_db = AudioServer.get_bus_volume_db(bus_index)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("toggle_fullscreen"):
        GameConfig.config.graphics.fullscreen = not GameConfig.config.graphics.fullscreen

    _update_graphics_window_size()
    _update_graphics_fullscreen_mode()
    _update_graphics_post_processing_mode()
    _update_graphics_crt_effect_mode()

    _update_sounds_master_bus()
    _update_sounds_ui_bus()
    _update_sounds_gameplay_bus()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_graphics_window_size():
    if Global.os_platform == "Desktop":
        var window: Window = get_window()
        if (
                window.size != GameConfig.RESOLUTIONS[GameConfig.config.graphics.resolution]
                and not GameConfig.config.graphics.fullscreen
        ):
            window.size = GameConfig.RESOLUTIONS[GameConfig.config.graphics.resolution]


func _update_graphics_fullscreen_mode() -> void:
    if Global.os_platform == "Desktop":
        var window: Window = get_window()
        match [ GameConfig.config.graphics.fullscreen, window.mode ]:
            [ false, Window.MODE_EXCLUSIVE_FULLSCREEN ]:
                window.mode = Window.MODE_WINDOWED
            [ true, _ ] when window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
                window.size = GameConfig.RESOLUTIONS[GameConfig.get_closest_resolution()]
                window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _update_graphics_post_processing_mode() -> void:
    var environment: Environment = post_processing_node.environment
    match [ GameConfig.config.graphics.post_processing, environment.background_mode ]:
        [ false, Environment.BG_CANVAS ]:
            environment.background_mode = Environment.BG_CLEAR_COLOR
        [ true, Environment.BG_CLEAR_COLOR ]:
            environment.background_mode = Environment.BG_CANVAS


func _update_graphics_crt_effect_mode() -> void:
    crt_effect_node.visible = GameConfig.config.graphics.crt_effect


func _update_sounds_master_bus() -> void:
    for bus_index in range(AudioServer.bus_count):
        if AudioServer.get_bus_name(bus_index) == "Master":
            var volume_percentage: float = (
                    GameConfig.config.sounds.master_volume
                    / GameConfig.VOLUME_SLIDER_MAX_VALUE
            )
            var volume_db: float = (
                    20.0 * log(volume_percentage) / log(10.0)
                    + _master_bus_max_volume_db
            )
            volume_db = clampf(volume_db, MIN_AUDIO_BUS_VOLUME_DB, MAX_AUDIO_BUS_VOLUME_DB)

            AudioServer.set_bus_volume_db(bus_index, volume_db)
            AudioServer.set_bus_mute(bus_index, GameConfig.config.sounds.master_muted)
            break


func _update_sounds_ui_bus() -> void:
    for bus_index in range(AudioServer.bus_count):
        if AudioServer.get_bus_name(bus_index) == "UI":
            var volume_percentage: float = (
                    GameConfig.config.sounds.ui_volume
                    / GameConfig.VOLUME_SLIDER_MAX_VALUE
            )
            var volume_db: float = (
                    20.0 * log(volume_percentage) / log(10.0)
                    + _ui_bus_max_volume_db
            )
            volume_db = clampf(volume_db, MIN_AUDIO_BUS_VOLUME_DB, MAX_AUDIO_BUS_VOLUME_DB)

            AudioServer.set_bus_volume_db(bus_index, volume_db)
            AudioServer.set_bus_mute(bus_index, GameConfig.config.sounds.ui_muted)
            break


func _update_sounds_gameplay_bus() -> void:
    for bus_index in range(AudioServer.bus_count):
        if AudioServer.get_bus_name(bus_index) == "Gameplay":
            var volume_percentage: float = (
                    GameConfig.config.sounds.gameplay_volume
                    / GameConfig.VOLUME_SLIDER_MAX_VALUE
            )
            var volume_db: float = (
                    20.0 * log(volume_percentage) / log(10.0)
                    + _gameplay_bus_max_volume_db
            )
            volume_db = clampf(volume_db, MIN_AUDIO_BUS_VOLUME_DB, MAX_AUDIO_BUS_VOLUME_DB)

            AudioServer.set_bus_volume_db(bus_index, volume_db)
            AudioServer.set_bus_mute(bus_index, GameConfig.config.sounds.gameplay_muted)
            break
#endregion
# ============================================================================ #
