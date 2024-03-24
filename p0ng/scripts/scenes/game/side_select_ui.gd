extends UI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    for child in get_tree().get_nodes_in_group("ui_scene_changer_buttons"):
        assert(child is Button, "ui_scene_changer_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_scene_changer_button_pressed)
#endregion
# ============================================================================ #
