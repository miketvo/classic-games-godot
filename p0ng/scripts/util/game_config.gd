extends Node2D
## Autoload singleton API for persistent game configuration.


# ============================================================================ #
#region Constants

## Save location for game configuration file.
const SAVE_PATH: StringName = "user://settings.cfg"

## Available game resolutions.
const RESOLUTIONS: Dictionary = {
    "640x360": Vector2(640, 360),
    "854x480": Vector2(854, 480),
    "960x540": Vector2(960, 540),
    "1024x576": Vector2(1024, 576),
    "1280x720": Vector2(1280, 720),
    "1366x768": Vector2(1366, 768),
    "1600x900": Vector2(1600, 900),
    "1920x1080": Vector2(1920, 1080),
    "2560x1440": Vector2(2560, 1440),
    "3200x1800": Vector2(3200, 1800),
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## 2-level [Dictionary] containing all persistent game configurations. The first
## level corresponds to sections in the configuration file (i.e. graphics,
## sounds, etc.). The second level corresponds to the key-value pair of
## configuration name and value within each section.
## [br][br]
## Automatically loaded at start of the game.
## [br][br]
## See [method reset_config] for sections, section keys, and their default
## values.
var config: Dictionary

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    var first_play: bool = not FileAccess.file_exists(SAVE_PATH)
    if first_play:
        reset_config()
        self._save()
    self._load()
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
func reset_config():
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


## Manually save current game configuration in memory into persistent storage.
## [br][br]
## See [constant SAVE_PATH] for save location.
func save_config():
    self._save()
    self._load()

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
            config[section][section_key] = config_file.get_value(section, section_key)


func _save() -> void:
    var config_file: ConfigFile = ConfigFile.new()
    for section in config.keys():
        var section_config: Dictionary = config[section]
        for section_key in section_config.keys():
            config_file.set_value(section, section_key, section_config[section_key])
    assert(
            config_file.save(SAVE_PATH) == OK,
            "Fatal error: Cannot write to %s" % ProjectSettings.globalize_path(SAVE_PATH)
    )


# Best resolution is defined as a resolution in [constant RESOLUTIONS] with the
# second closest area to the current monitor resolution. This is to avoid
# filling up the whole screen while in windowed mode, which might conflict with
# any OS task bar, menu bar, or dock.
func _get_best_resolution() -> Vector2:
    var current_resolution: Vector2 = get_viewport_rect().size
    var current_resolution_area: float = current_resolution.x * current_resolution.y
    var closest_distance = 99999999
    var closest_resolution = Vector2.ZERO
    var second_closest_resolution = Vector2.ZERO

    for possible_resolution in RESOLUTIONS.values():
        if (possible_resolution.x > current_resolution.x)\
                or (possible_resolution.y > current_resolution.y):
            break

        var possible_resolution_area: float = possible_resolution.x * possible_resolution.y
        var distance: float = abs(possible_resolution_area - current_resolution_area)
        if distance < closest_distance:
            second_closest_resolution = closest_resolution
            closest_resolution = possible_resolution
            closest_distance = distance
        elif distance < closest_distance and possible_resolution != closest_resolution:
            second_closest_resolution = possible_resolution

    return second_closest_resolution
#endregion
# ============================================================================ #
