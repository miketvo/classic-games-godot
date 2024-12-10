class_name OptionItem
extends CheckBox


signal selected(text: String)


# ============================================================================ #
#region Godot builtins
@warning_ignore("shadowed_variable_base_class")
func _init(
        name: StringName,
        text: String,
        button_group: ButtonGroup,
        flat: bool = true
) -> void:
    self.name = name
    self.text = text
    self.button_group = button_group
    self.flat = flat


func _ready() -> void:
    connect("pressed", _on_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners
func _on_pressed() -> void:
    selected.emit(text)
#endregion
# ============================================================================ #
