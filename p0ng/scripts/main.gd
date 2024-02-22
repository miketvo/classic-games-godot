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

        if OS.is_debug_build():
            print("========================================")
            print("LOADED SCENE '%s'" % SceneKey.keys()[_current_scene_key])
            print("Scene Tree:")
            print_tree_pretty()
            print("Current Stack:")
            print_stack()
            print("========================================")
            print()

    if Input.is_action_just_pressed("toggle_fullscreen"):
        match get_tree().root.mode:
            Window.MODE_EXCLUSIVE_FULLSCREEN:
                get_tree().root.mode = Window.MODE_WINDOWED
            Window.MODE_MINIMIZED:
                pass
            _:
                get_tree().root.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to _current_scene.scene_finished(next_scene_key: SceneKey)
func _on_scene_finished(next_scene_key: SceneKey) -> void:
    if OS.is_debug_build():
        print("========================================")
        print("UNLOADED SCENE '%s'" % SceneKey.keys()[_current_scene_key])
        print("Scene Tree:")
        print_tree_pretty()
        print("Current Stack:")
        print_stack()
        print("========================================")
        print()

    _current_scene.queue_free()
    remove_child(_current_scene)
    _current_scene_key = next_scene_key
    _current_scene = null

#endregion
# ============================================================================ #
