class_name GameConfigController
extends Node2D


@export var post_processing_node: WorldEnvironment
@export var crt_effect_node: ColorRect


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    # Set window size and center window. Workaround for:
    # https://github.com/godotengine/godot-proposals/issues/6247.
    # TODO: Reimplement this when there is better support for the above issue in
    # future Godot 4.x versions.
    var window: Window = get_window()
    window.size = GameConfig.RESOLUTIONS[GameConfig.config.graphics.resolution]
    @warning_ignore("integer_division")
    window.position = Vector2i(
            int(get_viewport_rect().size.x / 2) - window.size.x / 2,
            int(get_viewport_rect().size.y / 2) - window.size.y / 2
    )


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("toggle_fullscreen"):
        GameConfig.config.graphics.fullscreen = not GameConfig.config.graphics.fullscreen

    _update_window_size()
    _update_fullscreen_mode()
    _update_post_processing_mode()
    _update_crt_effect_mode()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_window_size():
    var window: Window = get_window()
    if (
            window.size != GameConfig.RESOLUTIONS[GameConfig.config.graphics.resolution]
            and not GameConfig.config.graphics.fullscreen
    ):
        window.size = GameConfig.RESOLUTIONS[GameConfig.config.graphics.resolution]


func _update_fullscreen_mode() -> void:
    var window: Window = get_window()
    match [ GameConfig.config.graphics.fullscreen, window.mode ]:
        [ false, Window.MODE_EXCLUSIVE_FULLSCREEN ]:
            window.mode = Window.MODE_WINDOWED
        [ true, _ ] when window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
            window.size = GameConfig.RESOLUTIONS[GameConfig.get_closest_resolution()]
            window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func _update_post_processing_mode() -> void:
    var environment: Environment = post_processing_node.environment
    match [ GameConfig.config.graphics.post_processing, environment.background_mode ]:
        [ false, Environment.BG_CANVAS ]:
            environment.background_mode = Environment.BG_CLEAR_COLOR
        [ true, Environment.BG_CLEAR_COLOR ]:
            environment.background_mode = Environment.BG_CANVAS


func _update_crt_effect_mode() -> void:
    match [ GameConfig.config.graphics.crt_effect, crt_effect_node.visible ]:
        [ false, true ]:
            crt_effect_node.visible = false
        [ true, false ]:
            crt_effect_node.visible = true
#endregion
# ============================================================================ #
