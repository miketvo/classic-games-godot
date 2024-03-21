extends PanelContainer


signal resolution_selected(resolution: String)

@export var option_button: Button

## Contains the [OptionItem] resolution buttons in the
## [code]$ResolutionPopup[/code].
var resolution_option_items: Array = Array()


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    option_button.connect("pressed", _on_option_button_pressed)
    visible = false

    var resolution_popup_button_group: ButtonGroup = ButtonGroup.new()
    var resolution_popup_container: Container = $ScrollContainer/VBoxContainer
    var resolution_keys: Array = GameConfig.RESOLUTIONS.keys()

    var i: int = 0
    for resolution_key in resolution_keys:
        var current_resolution: Vector2i = Vector2i(get_viewport_rect().size)
        var resolution: Vector2i = GameConfig.RESOLUTIONS[resolution_key]

        var resolution_option_item: OptionItem = OptionItem.new(
                "%sCheckBox" % resolution_key,
                resolution_key,
                resolution_popup_button_group
        )
        resolution_option_item.connect("selected", _on_resolution_option_item_selected)
        resolution_option_item.add_to_group("ui_accepted_buttons")
        resolution_popup_container.add_child(resolution_option_item)

        resolution_option_items.push_back(resolution_option_item)
        resolution_option_item.focus_neighbor_left = "."
        resolution_option_item.focus_neighbor_right = "."
        if i > 0:
            var prev_option_item_path: String = "../%s" % resolution_option_items[i - 1].name
            var this_option_item_path: String = "../%s" % resolution_option_item.name

            resolution_option_items[i - 1].focus_neighbor_bottom = NodePath(this_option_item_path)
            resolution_option_items[i - 1].focus_next = NodePath(this_option_item_path)
            resolution_option_item.focus_neighbor_top = NodePath(prev_option_item_path)
            resolution_option_item.focus_previous = NodePath(prev_option_item_path)

            if i == resolution_keys.size() - 1:
                var first_option_item = resolution_option_items[0]
                var first_option_item_path: String = "../%s" % first_option_item
                resolution_option_item.focus_neighbor_bottom = NodePath(first_option_item_path)
                resolution_option_item.focus_next = NodePath(first_option_item_path)
                first_option_item.focus_neighbor_top = NodePath(this_option_item_path)
                first_option_item.focus_previous = NodePath(this_option_item_path)

        if (
                resolution.x > current_resolution.x
                or resolution.y > current_resolution.y
        ):
            resolution_option_item.disabled = true

        i += 1


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        _close()


func _input(event: InputEvent) -> void:
    if (event is InputEventMouseButton) and event.pressed:
        var event_local_self = make_input_local(event)
        var event_local_option_button = option_button.make_input_local(event)
        if not (
                Rect2(Vector2(0, 0), size).has_point(event_local_self.position)
                or Rect2(Vector2(0, 0), option_button.size)\
                        .has_point(event_local_option_button.position)
        ):
            _close()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to resolution_option_items.[*].selected().
func _on_resolution_option_item_selected(text: String) -> void:
    if text != GameConfig.config.graphics.resolution:
        _close()
        option_button.text = text
        resolution_selected.emit(text)


# Listens to option_button
func _on_option_button_pressed() -> void:
    if visible:
        option_button.button_pressed = true
        return

    visible = true
    global_position = Vector2(
            option_button.global_position.x,
            (
                    option_button.global_position.y
                    + option_button.size.y
                    * scale.y
            )
    )

    for resolution_option_item in resolution_option_items:
        if resolution_option_item.text == GameConfig.config.graphics.resolution:
            resolution_option_item.grab_focus()
            break
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _close() -> void:
    visible = false
    option_button.button_pressed = false
    option_button.grab_focus()
#endregion
# ============================================================================ #
