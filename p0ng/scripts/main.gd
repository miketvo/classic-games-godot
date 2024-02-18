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
        get_tree().root.add_child(_current_scene)
        _current_scene.connect("scene_finished", _on_scene_finished)

        if OS.is_debug_build():
            print("========================================")
            print("LOADED SCENE '%s'" % SceneKey.keys()[_current_scene_key])
            print("Scene Tree:")
            self.print_tree()
            print("Orphan Nodes:")
            Node.print_orphan_nodes()
            print("Current Stack:")
            print_stack()
            print("========================================")
            print()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to _current_scene.scene_finished(next_scene_key: SceneKey)
func _on_scene_finished(next_scene_key: SceneKey) -> void:
    _current_scene.queue_free()
    get_tree().root.remove_child(_current_scene)

    if OS.is_debug_build():
        print("========================================")
        print("UNLOADED SCENE '%s'" % SceneKey.keys()[_current_scene_key])
        print("Scene Tree:")
        self.print_tree()
        print("Orphan Nodes:")
        Node.print_orphan_nodes()
        print("Current Stack:")
        print_stack()
        print("========================================")
        print()

    _set_next_scene(next_scene_key)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _set_next_scene(next_scene_key: SceneKey) -> void:
    # Scene change when [param next_scene_key] is provided
    if next_scene_key != SceneKey.NONE:
        _current_scene_key = next_scene_key
        return

    # Automatic scene change when [param next_scene_key] is NOT provided
    match _current_scene_key:
        SceneKey.SPLASH:
            _current_scene_key = SceneKey.MAIN_MENU
        SceneKey.GAME:
            _current_scene_key = SceneKey.MAIN_MENU
        SceneKey.MAIN_MENU, SceneKey.NONE:
            assert(false, "Not implemented")
        _:
            assert(false, "Unrecognized scene key")
#endregion
# ============================================================================ #
