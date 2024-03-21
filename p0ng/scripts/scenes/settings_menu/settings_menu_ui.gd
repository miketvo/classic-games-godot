extends UI


@export var settings_modified_message: String

@onready var _main: Container = $Main/Menu/VBoxContainer
@onready var _graphics: Container = $Graphics
@onready var _resolution_popup: Container = $ResolutionPopup
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
    if Global.os_platform == "Desktop":
        _resolution_popup.connect("resolution_selected", _on_resolution_popup_resolution_selected)
    else:
        _graphics.get_node("Resolution").hide()
    _graphics.get_node("Fullscreen/ToggleButton")\
            .connect("toggled", _on_graphics_fullscreen_toggled)
    _graphics.get_node("PostProcessing/ToggleButton")\
            .connect("toggled", _on_graphics_post_processing_toggled)
    _graphics.get_node("CrtEffect/ToggleButton")\
            .connect("toggled", _on_graphics_crt_effect_toggled)
    _graphics.get_node("Menu/BackButton").connect("pressed", _on_graphics_menu_back_button_pressed)
    _sounds.get_node("MasterVolume/HSlider")\
            .connect("drag_ended", _on_sounds_master_volume_slider_updated)
    _sounds.get_node("MasterVolume/MuteToggleButton")\
            .connect("toggled", _on_sounds_master_volume_mute_toggled)
    _sounds.get_node("UIVolume/HSlider")\
            .connect("drag_ended", _on_sounds_ui_volume_slider_updated)
    _sounds.get_node("UIVolume/MuteToggleButton")\
            .connect("toggled", _on_sounds_ui_volume_mute_toggled)
    _sounds.get_node("GameplayVolume/HSlider")\
            .connect("drag_ended", _on_sounds_gameplay_volume_slider_updated)
    _sounds.get_node("GameplayVolume/MuteToggleButton")\
            .connect("toggled", _on_sounds_gameplay_volume_mute_toggled)
    _sounds.get_node("Menu/BackButton").connect("pressed", _on_sounds_menu_back_button_pressed)
    _reset_defaults.get_node("Menu/ProceedButton")\
            .connect("pressed", _on_reset_defaults_menu_proceed_button_pressed)
    _reset_defaults.get_node("Menu/CancelButton")\
            .connect("pressed", _on_reset_defaults_menu_cancel_button_pressed)
    _reset_defaults.get_node("ResetCooldownTimer")\
            .connect("timeout", _on_reset_defaults_reset_cooldown_timer_timeout)

    _graphics.get_node("Menu/MessageLabel").text = ""
    _sounds.get_node("Menu/MessageLabel").text = ""
    _reset_defaults.get_node("WarningLabel").visible = true
    _reset_defaults.get_node("DoneLabel").visible = false

    for child in get_tree().get_nodes_in_group("ui_container_slider_buttons"):
        assert(child is Button, "ui_container_slider_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_container_slider_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_scene_changer_buttons"):
        assert(child is Button, "ui_scene_changer_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_scene_changer_button_pressed)
    for child in get_tree().get_nodes_in_group("ui_selected_buttons"):
        assert(child is Button, "ui_selected_buttons group must contain only Buttons")
        child.connect("pressed", _on_ui_selected_button_pressed)
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


func _process(_delta: float) -> void:
    _update_graphics_save_button()
    _update_sounds_save_button()


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
    acted.emit("back_to_main_menu")
#endregion


#region Listens to _graphics.get_node("*").
func _on_graphics_fullscreen_toggled(toggled_on: bool) -> void:
    _graphics.get_node("Resolution/OptionButton").disabled = toggled_on
    acted_with_data.emit("graphics_fullscreen_toggled", toggled_on)


func _on_graphics_post_processing_toggled(toggled_on: bool) -> void:
    acted_with_data.emit("graphics_post_processing_toggled", toggled_on)


func _on_graphics_crt_effect_toggled(toggled_on: bool) -> void:
    acted_with_data.emit("graphics_crt_effect_toggled", toggled_on)


func _on_graphics_menu_save_button_pressed() -> void:
    acted_with_data.emit("save", "graphics")


func _on_graphics_menu_back_button_pressed() -> void:
    input_disabled = true
    _main.get_node("GraphicsButton").grab_focus()
    tween_transition_slide_container(_graphics, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($Main, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
#endregion


# Listens to resolution_option_items.[*].selected().
func _on_resolution_popup_resolution_selected(resolution: String) -> void:
    acted_with_data.emit(
            "graphics_resolution_selected",
            resolution
    )


#region Listens to _sounds.get_node("*").
func _on_sounds_master_volume_slider_updated(_value_changed: bool) -> void:
    var slider: Range = _sounds.get_node("MasterVolume/HSlider")
    acted_with_data.emit("sounds_master_volume_slider_updated", slider.value)


func _on_sounds_master_volume_mute_toggled(toggled_on: bool) -> void:
    _sounds.get_node("MasterVolume/HSlider").editable = not toggled_on
    acted_with_data.emit("sounds_master_volume_mute_toggled", toggled_on)


func _on_sounds_ui_volume_slider_updated(_value_changed: bool) -> void:
    var slider: Range = _sounds.get_node("UIVolume/HSlider")
    acted_with_data.emit("sounds_ui_volume_slider_updated", slider.value)


func _on_sounds_ui_volume_mute_toggled(toggled_on: bool) -> void:
    _sounds.get_node("UIVolume/HSlider").editable = not toggled_on
    acted_with_data.emit("sounds_ui_volume_mute_toggled", toggled_on)


func _on_sounds_gameplay_volume_slider_updated(_value_changed: bool) -> void:
    var slider: Range = _sounds.get_node("GameplayVolume/HSlider")
    acted_with_data.emit("sounds_gameplay_volume_slider_updated", slider.value)


func _on_sounds_gameplay_volume_mute_toggled(toggled_on: bool) -> void:
    _sounds.get_node("GameplayVolume/HSlider").editable = not toggled_on
    acted_with_data.emit("sounds_gameplay_volume_mute_toggled", toggled_on)


func _on_sounds_menu_save_button_pressed() -> void:
    acted_with_data.emit("save", "sounds")


func _on_sounds_menu_back_button_pressed() -> void:
    input_disabled = true
    _main.get_node("SoundsButton").grab_focus()
    tween_transition_slide_container(_sounds, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($Main, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
#endregion


#region Listens to _reset_defaults.get_node("*").
func _on_reset_defaults_menu_proceed_button_pressed() -> void:
    input_disabled = true
    _reset_defaults.get_node("ResetCooldownTimer").start()
    _reset_defaults.get_node("WarningLabel").visible = false
    _reset_defaults.get_node("DoneLabel").visible = true
    acted.emit("reset_defaults")


func _on_reset_defaults_menu_cancel_button_pressed() -> void:
    input_disabled = true
    _main.get_node("ResetButton").grab_focus()
    tween_transition_slide_container(_reset_defaults, Vector2.DOWN, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container($Main, Vector2.DOWN, UI_TRANSITION_DURATION, 12.0)\
            .connect("finished", _on_tween_transition_finshed)


func _on_reset_defaults_reset_cooldown_timer_timeout() -> void:
    input_disabled = true
    _main.get_node("ResetButton").grab_focus()
    tween_transition_slide_container(_reset_defaults, Vector2.DOWN, UI_TRANSITION_DURATION)\
            .connect("finished", _on_reset_defaults_tween_transitioned)
    tween_transition_slide_container($Main, Vector2.DOWN, UI_TRANSITION_DURATION, 12.0)\
            .connect("finished", _on_reset_defaults_tween_transitioned)
#endregion


# Listens to item_selected(index: int) of ui_scene_changer_buttons that is of
# type OptionButton.
func _on_option_button_item_selected(_index: int) -> void:
    _on_ui_accepted_button_pressed()


# Listens to drag_ended(value_changed: bool) of ui_scene_changer_buttons that is
# of type Slider.
func _on_slider_drag_ended(_value_changed: bool) -> void:
    _on_ui_accepted_button_pressed()


# Listens to tween transition Tween.finished() from reset_defaults to re-enable
# input and reset labels.
func _on_reset_defaults_tween_transitioned():
    _on_tween_transition_finshed()
    _reset_defaults.get_node("WarningLabel").visible = true
    _reset_defaults.get_node("DoneLabel").visible = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_graphics_save_button() -> void:
    var is_config_graphics_modified: bool = GameConfig.is_modified("graphics")
    var graphics_message_label: Label = _graphics.get_node("Menu/MessageLabel")
    var graphics_save_button: Button = _graphics.get_node("Menu/SaveButton")
    match [
        is_config_graphics_modified,
        graphics_message_label.text,
        graphics_save_button.flat,
    ]:
        [ true, "", true ]:
            graphics_message_label.text = settings_modified_message
            graphics_save_button.flat = false
            if graphics_save_button.is_in_group("ui_disabled_buttons"):
                graphics_save_button.disconnect("pressed", _on_ui_disabled_button_pressed)
                graphics_save_button.remove_from_group("ui_disabled_buttons")
                graphics_save_button.add_to_group("ui_accepted_buttons")
                graphics_save_button.connect("pressed", _on_ui_accepted_button_pressed)
                graphics_save_button.connect("pressed", _on_graphics_menu_save_button_pressed)
        [ false, _, false ]:
            graphics_message_label.text = ""
            graphics_save_button.flat = true
            if graphics_save_button.is_in_group("ui_accepted_buttons"):
                graphics_save_button.disconnect("pressed", _on_ui_accepted_button_pressed)
                graphics_save_button.remove_from_group("ui_accepted_buttons")
                graphics_save_button.add_to_group("ui_disabled_buttons")
                graphics_save_button.connect("pressed", _on_ui_disabled_button_pressed)
                graphics_save_button.disconnect("pressed", _on_graphics_menu_save_button_pressed)


func _update_sounds_save_button() -> void:
    var is_config_sounds_modified: bool = GameConfig.is_modified("sounds")
    var sounds_message_label: Label = _sounds.get_node("Menu/MessageLabel")
    var sounds_save_button: Button = _sounds.get_node("Menu/SaveButton")
    match [
        is_config_sounds_modified,
        sounds_message_label.text,
        sounds_save_button.flat,
    ]:
        [ true, "", true ]:
            sounds_message_label.text = settings_modified_message
            sounds_save_button.flat = false
            if sounds_save_button.is_in_group("ui_disabled_buttons"):
                sounds_save_button.disconnect("pressed", _on_ui_disabled_button_pressed)
                sounds_save_button.remove_from_group("ui_disabled_buttons")
                sounds_save_button.add_to_group("ui_accepted_buttons")
                sounds_save_button.connect("pressed", _on_ui_accepted_button_pressed)
                sounds_save_button.connect("pressed", _on_sounds_menu_save_button_pressed)
        [ false, _, false ]:
            sounds_message_label.text = ""
            sounds_save_button.flat = true
            if sounds_save_button.is_in_group("ui_accepted_buttons"):
                sounds_save_button.disconnect("pressed", _on_ui_accepted_button_pressed)
                sounds_save_button.remove_from_group("ui_accepted_buttons")
                sounds_save_button.add_to_group("ui_disabled_buttons")
                sounds_save_button.connect("pressed", _on_ui_disabled_button_pressed)
                sounds_save_button.disconnect("pressed", _on_sounds_menu_save_button_pressed)
#endregion
# ============================================================================ #
