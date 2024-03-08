extends Node2D
## Autoload singleton API for persistent game configuration. Stores
## globally-accessible game configuration. See [member config].


# ============================================================================ #
#region Constants

## Save location for game configuration file.
const SAVE_PATH: StringName = "user://settings.cfg"

## Available game resolutions.
const RESOLUTIONS: Dictionary = {
    "640x360": Vector2i(640, 360),
    "854x480": Vector2i(854, 480),
    "960x540": Vector2i(960, 540),
    "1024x576": Vector2i(1024, 576),
    "1280x720": Vector2i(1280, 720),
    "1366x768": Vector2i(1366, 768),
    "1600x900": Vector2i(1600, 900),
    "1920x1080": Vector2i(1920, 1080),
    "2560x1440": Vector2i(2560, 1440),
    "3200x1800": Vector2i(3200, 1800),
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## 2-level [Dictionary] containing persistent game configuration. The first
## level corresponds to sections in the configuration file (i.e. graphics,
## sounds, etc.). The second level corresponds to the key-value pair of
## configuration name and value within each section.
## [br][br]
## Automatically loaded at start of the game.
## [br][br]
## See [method reset_config] for sections, section keys, and their default
## values.
var config: Dictionary
var _original_config: Dictionary

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    reset_config()
    var first_play: bool = not FileAccess.file_exists(SAVE_PATH)
    if first_play:
        self._save()
    self._load()

    # Set window size and center window. Workaround for:
    # https://github.com/godotengine/godot-proposals/issues/6247.
    # TODO: Reimplement this when there is better support for the above issue in
    # future Godot 4.x versions.
    var window: Window = get_window()
    window.size = RESOLUTIONS[config.graphics.resolution]
    @warning_ignore("integer_division")
    window.position = Vector2i(
            int(get_viewport_rect().size.x / 2) - window.size.x / 2,
            int(get_viewport_rect().size.y / 2) - window.size.y / 2
    )


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("toggle_fullscreen"):
        config.graphics.fullscreen = not config.graphics.fullscreen

    var window: Window = get_window()
    match [ config.graphics.fullscreen, window.mode ]:
        [ false, Window.MODE_EXCLUSIVE_FULLSCREEN ]:
            window.mode = Window.MODE_WINDOWED
        [ true, _ ] when window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
            window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Reset all configuration in memory to default values. Does [b]NOT[/b] save it
## into persistent storage.
## [br][br]
## See method body for default values.
## [br][br]
## See [constant SAVE_PATH] for save location.
func reset_config() -> void:
    config = {
        "graphics": {
            "resolution": _get_best_resolution(),
            "fullscreen": false,
            "post_processing": true,
            "crt_effect": true,
        },
        "sounds": {
            "master_volume": 100.0,
            "master_muted": false,
            "ui_volume": 100.0,
            "ui_muted": false,
            "gameplay_volume": 100.0,
            "gameplay_muted": false,
        },
    }
    save_config()


## Manually save current game configuration in memory into persistent storage.
## [br][br]
## See [constant SAVE_PATH] for save location.
## [br][br]
## Specify [param section] to only save that section in the game configuration.
## [br][br]
## See [member config] for game configuration structure.
func save_config(section: StringName = "") -> void:
    self._save(section)
    self._load()


## Returns true if the current game configuration is different from the content
## of the game configuration file at [constant SAVE_PATH].
## [br][br]
## Specify [param section] to only check for changes in that section in the game
## configuration.
## [br][br]
## See [member config] for game configuration structure.
func is_modified(section: StringName = "") -> bool:
    if section == "":
        return _original_config != config
    else:
        return _original_config[section] != config[section]
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _load() -> void:
    var config_file: ConfigFile = ConfigFile.new()
    var err: int = config_file.load(SAVE_PATH)
    assert(
            err == OK,
            "Fatal error: Cannot read from %s" % ProjectSettings.globalize_path(SAVE_PATH)
    )
    for section in config_file.get_sections():
        for section_key in config_file.get_section_keys(section):
            _original_config[section][section_key] = config_file.get_value(section, section_key)
    config = _original_config.duplicate(true)


func _save(target_section: StringName = "") -> void:
    var config_file: ConfigFile = ConfigFile.new()
    for section in config.keys():
        if (target_section != "") and (target_section != section):
            continue
        var section_config: Dictionary = config[section]
        for section_key in section_config.keys():
            config_file.set_value(section, section_key, section_config[section_key])
    assert(
            config_file.save(SAVE_PATH) == OK,
            "Fatal error: Cannot write to %s" % ProjectSettings.globalize_path(SAVE_PATH)
    )
    _original_config = config.duplicate(true)


# Best resolution is defined as a resolution in [constant RESOLUTIONS] with the
# second closest area to the current monitor resolution. This is to avoid
# filling up the whole screen while in windowed mode, which might conflict with
# any OS task bar, menu bar, or dock.
func _get_best_resolution() -> StringName:
    var closest_resolution: StringName = ""
    var second_closest_resolution: StringName = ""
    var current_resolution: Vector2i = Vector2i(get_viewport_rect().size)
    var current_resolution_area: int = current_resolution.x * current_resolution.y
    var closest_distance: int = 99999999

    for resolution_key in RESOLUTIONS.keys():
        var resolution = RESOLUTIONS[resolution_key]
        if (resolution.x > current_resolution.x)\
                or (resolution.y > current_resolution.y):
            break

        var resolution_area: int = resolution.x * resolution.y
        var distance: int = abs(resolution_area - current_resolution_area)
        if distance < closest_distance:
            second_closest_resolution = closest_resolution
            closest_resolution = resolution_key
            closest_distance = distance
        elif distance < closest_distance and resolution_key != closest_resolution:
            second_closest_resolution = resolution_key

    return second_closest_resolution
#endregion
# ============================================================================ #
