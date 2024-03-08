extends GameScene2D
## Game entry point


var _current_scene_key: SceneKey
var _current_scene: Node


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _current_scene_key = SceneKey.SPLASH
    _current_scene = null


func _process(_delta: float) -> void:
    if _current_scene == null:
        _current_scene = load(GAME_SCENE[_current_scene_key]).instantiate()
        add_child(_current_scene)
        move_child(_current_scene, 0)
        _current_scene.connect("scene_finished", _on_scene_finished)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _current_scene.scene_finished(next_scene_key: SceneKey)
func _on_scene_finished(next_scene_key: SceneKey) -> void:
    _current_scene.queue_free()
    remove_child(_current_scene)
    _current_scene_key = next_scene_key
    _current_scene = null

#endregion
# ============================================================================ #
