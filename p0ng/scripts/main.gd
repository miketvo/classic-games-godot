extends GameScene2D
## Game entry point


var _next_scene_key: SceneKey
var _current_scene: Node


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _next_scene_key = SceneKey.SPLASH
    _current_scene = null


func _process(_delta: float) -> void:
    if _current_scene == null:
        _current_scene = load(GAME_SCENE[_next_scene_key]).instantiate()
        get_tree().root.add_child(_current_scene)
        _current_scene.connect("scene_finished", _on_scene_finished)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners
func _on_scene_finished(next_scene_key: SceneKey) -> void:
    _current_scene.queue_free()
    get_tree().root.remove_child(_current_scene)
    _current_scene = null
    set_next_scene(next_scene_key)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func set_next_scene(next_scene_key: SceneKey) -> void:
    # Scene change when [param next_scene_key] is provided
    if next_scene_key != SceneKey.NONE:
        _next_scene_key = next_scene_key
        return

    # Automatic scene change when [param next_scene_key] is NOT provided
    match _next_scene_key:
        SceneKey.SPLASH:
            _next_scene_key = SceneKey.MAIN_MENU
        _:
            assert(false, "Unrecognized scene key")
#endregion
# ============================================================================ #
