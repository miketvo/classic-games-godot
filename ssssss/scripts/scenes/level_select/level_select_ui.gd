extends UI


@export var parent: GameScene2D
var _selected_level: int
var _level_select_buttons: Array[Button]


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(parent, "`parent` must be set")
    parent.load_succeeded.connect(_on_load_succeeded)
    parent.load_failed.connect(_on_load_failed)

    %BackButton.pressed.connect(_on_back_button_pressed)
    %PlayButton.pressed.connect(_on_play_button_pressed)
    %PreviousLevelButton.pressed.connect(_on_previous_level_button_pressed)
    %NextLevelButton.pressed.connect(_on_next_level_button_pressed)

    for child in get_tree().get_nodes_in_group("ui_container_slider_buttons"):
        assert(child is Button, "ui_container_slider_buttons group must contain only Buttons")
        child.pressed.connect(_on_ui_container_slider_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_scene_changer_buttons"):
        assert(child is Button, "ui_scene_changer_buttons group must contain only Buttons")
        child.pressed.connect(_on_ui_scene_changer_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_selected_buttons"):
        assert(child is Button, "ui_selected_buttons group must contain only Buttons")
        child.pressed.connect(_on_ui_selected_button_pressed)

    _selected_level = 0
    _level_select_buttons = []
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to parent.load_succeeded().
func _on_load_succeeded() -> void:
    %LoadFailedLabel.visible = false
    %PlayButton.disabled = false
    var level_select_button_group: ButtonGroup = ButtonGroup.new()
    for level in Global.levels:
        var level_number: int = level["metadata"]["order"]
        var level_name: String = level["metadata"]["name"]

        var level_select_button: Button = Button.new()
        level_select_button.name = "Level%dSelectButton" % level_number
        level_select_button.text = "level %d\n%s" % [level_number, level_name.to_upper()]
        level_select_button.button_group = level_select_button_group
        level_select_button.toggle_mode = true
        level_select_button.custom_minimum_size = Vector2(180, 0)
        level_select_button.add_to_group("ui_selected_buttons")
        level_select_button.connect("pressed", _on_level_select_button_pressed)
        level_select_button.connect("pressed", _on_ui_selected_button_pressed)

        %LevelListContainer.add_child(level_select_button)
        _level_select_buttons.append(level_select_button)

        if level_number == _selected_level + 1:
            level_select_button.button_pressed = true

    _update_level_preview()
    %BackButton.grab_focus()


# Listens to parent.load_failed().
func _on_load_failed() -> void:
    %LoadFailedLabel.visible = true
    %PlayButton.disabled = true


# Listens to %BackButton.pressed().
func _on_back_button_pressed() -> void:
    acted.emit("back_to_main_menu")


# Listens to %BackButton.pressed().
func _on_play_button_pressed() -> void:
    acted_with_data.emit("play_game", _selected_level)


# Listens to %PreviousLevelButton.pressed().
func _on_previous_level_button_pressed() -> void:
    _selected_level = posmod(_selected_level - 1, _level_select_buttons.size())
    _level_select_buttons[_selected_level].button_pressed = true
    _update_level_preview()
    _auto_scroll()


# Listens to %NextLevelButton.pressed().
func _on_next_level_button_pressed() -> void:
    _selected_level = posmod(_selected_level + 1, _level_select_buttons.size())
    _level_select_buttons[_selected_level].button_pressed = true
    _update_level_preview()
    _auto_scroll()


# Listens to %LevelListContainer.get_node("*").pressed().
func _on_level_select_button_pressed() -> void:
    for i in range(_level_select_buttons.size()):
        if _level_select_buttons[i].button_pressed:
            _selected_level = i
            _update_level_preview()
            return

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_level_preview() -> void:
    var preview_file: String = Global.levels[_selected_level]["metadata"]["preview"]
    if preview_file == Global.LEVEL_PREVIEW_DIRECTORY.path_join(""):
        preview_file = Global.LEVEL_PREVIEW_NULL
    %LevelPreview.texture = load(preview_file)


func _auto_scroll():
    var _scroll_container: ScrollContainer = %LevelListContainer.get_parent()
    assert(_scroll_container, "LevelListContainer: ScrollContainer parent not found")
    _scroll_container.ensure_control_visible(_level_select_buttons[_selected_level])
#endregion
# ============================================================================ #
