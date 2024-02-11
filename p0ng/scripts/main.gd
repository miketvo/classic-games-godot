extends GameScene
## Game entry point


var _next_scene_key: String
var _current_scene: Node


# ============================================================================ #
#region Game loop
func _ready() -> void:
    _next_scene_key = "splash"
    _current_scene = null


func _process(_delta: float) -> void:
    if _current_scene == null:
        _current_scene = load(Global.GAME_SCENE[_next_scene_key]).instantiate()
        get_tree().root.add_child(_current_scene)
        _current_scene.connect("scene_finished", _on_scene_finished)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners
func _on_scene_finished(next_scene_key):
    _current_scene.queue_free()
    get_tree().root.remove_child(_current_scene)
    _current_scene = null
    set_next_scene(next_scene_key)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func set_next_scene(next_scene_key: String):
    if next_scene_key == "":
        _next_scene_key = next_scene_key
        return

    match _next_scene_key:
        "splash":
            _next_scene_key = "main_menu"
        _:
            assert(false, "Unrecognized scene key")
#endregion
# ============================================================================ #
