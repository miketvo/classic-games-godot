extends Node2D


# ============================================================================ #
#region Constants
const SAVE_PATH: StringName = "user://settings.cfg"
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

#region Graphics settings
var resolution: Vector2
var fullscreen: bool
var post_processing: bool
var crt_effect: bool
#endregion

#region Graphics settings
var master_volume: float
var master_muted: bool
var ui_volume: float
var ui_muted: bool
var gameplay_volume: float
var gameplay_muted: bool
#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    var first_play: bool = not FileAccess.file_exists(SAVE_PATH)
    if first_play:
        resolution = _get_best_resolution()
        fullscreen = false
        post_processing = true
        crt_effect = true
        master_volume = 100.0
        master_muted = false
        ui_volume = 100.0
        ui_muted = false
        gameplay_volume = 100.0
        gameplay_muted = false
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func load() -> void:
    var config: ConfigFile = ConfigFile.new()


func save() -> void:
    var config: ConfigFile = ConfigFile.new()


func _get_best_resolution() -> Vector2:
    var current_resolution: Vector2 = get_viewport_rect().size
    var closest_distance = 99999999
    var best_resolution = Vector2.ZERO
    for possible_resolution in RESOLUTIONS.values():
        var distance: float = abs(
                    possible_resolution.x * possible_resolution.y\
                            - current_resolution.x * current_resolution.y
            )
        if distance < closest_distance:
            best_resolution = possible_resolution
            closest_distance = distance

    print(best_resolution)
    return best_resolution
#endregion
# ============================================================================ #
