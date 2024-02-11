extends Node2D
## Game entry point


const GAME_SCENE = {
    "splash": "res://scenes/splash.tscn",
    "main_menu": "res://scenes/main_menu/main_menu.tscn",
}

var next_scene_key: String
var current_scene: Node


# =========================================================================== #
#region Game loop
func _ready() -> void:
    next_scene_key = "splash"
    current_scene = null


func _process(_delta: float) -> void:
    if current_scene == null:
        current_scene = load(GAME_SCENE[next_scene_key]).instantiate()
        get_tree().root.add_child(current_scene)
        current_scene.connect("scene_finished", _on_scene_finished)
#endregion
# =========================================================================== #


# =========================================================================== #
#region Signal listeners
func _on_scene_finished():
    current_scene.queue_free()
    get_tree().root.remove_child(current_scene)
    current_scene = null
    set_next_scene()
#endregion
# =========================================================================== #


# =========================================================================== #
#region Utils
func set_next_scene():
    match next_scene_key:
        "splash":
            next_scene_key = "main_menu"
#endregion
# =========================================================================== #
