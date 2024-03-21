extends PanelContainer


@export var option_button: Button


# ============================================================================ #
#region Godot builtins
func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        visible = false
        option_button.button_pressed = false


func _input(event: InputEvent) -> void:
    if (event is InputEventMouseButton) and event.pressed:
        var event_local_self = make_input_local(event)
        var event_local_option_button = option_button.make_input_local(event)
        if not (
                Rect2(Vector2(0, 0), size).has_point(event_local_self.position)
                or Rect2(Vector2(0, 0), option_button.size)\
                        .has_point(event_local_option_button.position)
        ):
            visible = false
            option_button.button_pressed = false
            option_button.grab_focus()
#endregion
# ============================================================================ #
