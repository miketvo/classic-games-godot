extends UI


@export var parent: GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(parent, "`parent` must be set")
    parent.load_succeeded.connect(_on_load_succeeded)
    parent.load_failed.connect(_on_load_failed)

    %BackButton.pressed.connect(_on_back_button_pressed)
    %PlayButton.pressed.connect(_on_play_button_pressed)

    for child in get_tree().get_nodes_in_group("ui_container_slider_buttons"):
        assert(child is Button, "ui_container_slider_buttons group must contain only Buttons")
        child.pressed.connect(_on_ui_container_slider_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_scene_changer_buttons"):
        assert(child is Button, "ui_scene_changer_buttons group must contain only Buttons")
        child.pressed.connect(_on_ui_scene_changer_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_selected_buttons"):
        assert(child is Button, "ui_selected_buttons group must contain only Buttons")
        child.pressed.connect(_on_ui_selected_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to parent.load_succeeded().
func _on_load_succeeded() -> void:
    %LoadFailedLabel.visible = false
    var level_select_button_group: ButtonGroup = ButtonGroup.new()
    for level in Global.levels:
        var level_number: int = level["metadata"]["order"]
        var level_name: String = level["metadata"]["name"]

        var level_select_button: Button = Button.new()
        level_select_button.name = "Level%dSelectButton" % level_number
        level_select_button.text = "level %d\n%s" % [level_number, level_name.to_upper()]
        level_select_button.button_group = level_select_button_group
        level_select_button.add_to_group("ui_selected_buttons")
        level_select_button.connect("pressed", _on_ui_selected_button_pressed)

        %LevelListContainer.add_child(level_select_button)


# Listens to parent.load_failed().
func _on_load_failed() -> void:
    %LoadFailedLabel.visible = true


# Listens to %BackButton.pressed().
func _on_back_button_pressed() -> void:
    acted.emit("back_to_main_menu")


# Listens to %BackButton.pressed().
func _on_play_button_pressed() -> void:
    acted_with_data.emit("play_game", 1) # TODO: Replace this with dynamic level index value.

#endregion
# ============================================================================ #
