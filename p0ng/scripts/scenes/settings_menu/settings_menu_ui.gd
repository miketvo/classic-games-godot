extends UI


var input_disabled: bool

@onready var _main: Container = $Main/Menu/VBoxContainer
@onready var _graphics: Container = $Graphics
@onready var _sounds: Container = $Sounds
@onready var _reset_defaults: Container = $ResetDefaults


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    super()
    input_disabled = false
    _main.get_node("BackButton").grab_focus()
    _main.get_node("BackButton").connect("pressed", _on_main_back_button_pressed)
    _main.get_node("GraphicsButton").connect("pressed", _on_main_graphics_button_pressed)
    _main.get_node("SoundsButton").connect("pressed", _on_main_sounds_button_pressed)
    _main.get_node("ResetButton").connect("pressed", _on_main_reset_button_pressed)
    _graphics.get_node("Menu/BackButton").connect("pressed", _on_graphics_menu_back_button_pressed)
    _sounds.get_node("Menu/BackButton").connect("pressed", _on_sounds_menu_back_button_pressed)
    _reset_defaults.get_node("Menu/CancelButton")\
            .connect("pressed", _on_reset_defaults_menu_cancel_button_pressed)

    for child in get_tree().get_nodes_in_group("ui_container_slider_buttons"):
        assert(child is Button, "ui_container_slider_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_container_slider_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_scene_changer_buttons"):
        assert(child is Button, "ui_scene_changer_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_scene_changer_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_selected_buttons"):
        assert(child is Button, "ui_selected_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_selected_button_pressed)
        if child is OptionButton:
            child.connect("item_selected", _on_option_button_item_selected)
    for child in get_tree().get_nodes_in_group("ui_accepted_buttons"):
        assert(
                (child is Button) or (child is Slider),
                "ui_accepted_buttons group must contain only Buttons or Slider"
        )
        if child is Slider:
            child.connect("drag_ended", _on_slider_drag_ended)
        elif child is Button:
            child.connect("pressed", _on_ui_accepted_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_disabled_buttons"):
        assert(child is Button, "ui_disabled_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_disabled_button_pressed)


func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

#region Listens to _main.get_node("*").
func _on_main_graphics_button_pressed() -> void:
    input_disabled = true
    _graphics.get_node("Resolution/OptionButton").grab_focus()
    tween_transition_slide_container($Main, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container(_graphics, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)


func _on_main_sounds_button_pressed() -> void:
    input_disabled = true
    _sounds.get_node("MasterVolume/HSlider").grab_focus()
    tween_transition_slide_container($Main, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container(_sounds, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)


func _on_main_reset_button_pressed() -> void:
    input_disabled = true
    _reset_defaults.get_node("Menu/CancelButton").grab_focus()
    tween_transition_slide_container($Main, Vector2.UP, UI_TRANSITION_DURATION, 12.0)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container(_reset_defaults, Vector2.UP, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)


func _on_main_back_button_pressed() -> void:
    button_pressed.emit("back_to_main_menu")
#endregion


#region Listens to _graphics.get_node("*").
func _on_graphics_menu_back_button_pressed() -> void:
    input_disabled = true
    _main.get_node("GraphicsButton").grab_focus()
    tween_transition_slide_container(_graphics, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($Main, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
#endregion


#region Listens to _sounds.get_node("*").
func _on_sounds_menu_back_button_pressed() -> void:
    input_disabled = true
    _main.get_node("SoundsButton").grab_focus()
    tween_transition_slide_container(_sounds, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($Main, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
#endregion


#region Listens to _reset_defaults.get_node("*").
func _on_reset_defaults_menu_cancel_button_pressed() -> void:
    input_disabled = true
    _main.get_node("ResetButton").grab_focus()
    tween_transition_slide_container(_reset_defaults, Vector2.DOWN, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($Main, Vector2.DOWN, UI_TRANSITION_DURATION, 12.0)\
            .connect("finished", _on_tween_transition_finshed)
#endregion


# Listens to item_selected(index: int) of ui_scene_changer_buttons that is of
# type OptionButton.
func _on_option_button_item_selected(_index: int) -> void:
    _on_ui_accepted_button_pressed()


# Listens to drag_ended(value_changed: bool) of ui_scene_changer_buttons that is
# of type Slider.
func _on_slider_drag_ended(value_changed: bool) -> void:
    if value_changed:
        _on_ui_accepted_button_pressed()


# Listens to tween transition Tween.finished() to re-enable input.
func _on_tween_transition_finshed() -> void:
    input_disabled = false

#endregion
# ============================================================================ #
