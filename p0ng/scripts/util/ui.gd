class_name UI
extends Control


signal acted(action: StringName)
const UI_TRANSITION_DURATION: float = 0.5
@onready var _sfx_controller: SfxController


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _sfx_controller = get_tree().root.get_node("Main/UISfxController")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Creates a fade-in transition effect for a container node using a Tween node.
## [br][br]
## [b]Parameters:[/b][br]
## - [param container]: The container node to apply the fade-in
##   transition effect.[br]
## - [param duration]: The duration of the fade-in transition effect in
##   seconds.
## [br][br]
## [b]Returns:[/b][br]
## - The [Tween] responsible for the transition effect.
func tween_transition_fade_appear_container(
        container: Container,
        duration: float
) -> Tween:
    var tween: Tween = create_tween()
    tween.tween_property(
            container, "modulate",
            Color(1.0, 1.0, 1.0, 1.0),
            duration
    ).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    return tween


## Creates a slide transition effect for a container node using a Tween node.
## [br][br]
## [b]Parameters:[/b][br]
## - [param container]: The container node to apply the slide
##   transition effect.[br]
## - [param direction]: The direction of the slide transition. A unit vector is
##   expected (e.g., [constant Vector2.LEFT], [constant Vector2.RIGHT],
##   [constant Vector2.UP], [constant Vector2.DOWN]). An assertion error is
##   thrown if an invalid value is provided.[br]
## - [param duration]: The duration of the slide transition effect in
##   seconds.[br]
## - [param pad] (optional): Optional padding to adjust the movement scale of
##   the slide transition. Default value is 0.0.
## [br][br]
## [b]Returns:[/b][br]
## - The [Tween] responsible for the transition effect.
func tween_transition_slide_container(
        container: Container,
        direction: Vector2,
        duration: float,
        pad: float = 0.0
) -> Tween:
    assert(
            direction in Global.UNIT_VECTORS,
            "UI.tween_transition_slide_container() only accepts unit vector for `direction`"
    )

    var movement_scale: float
    if direction in [ Vector2.LEFT, Vector2.RIGHT ]:
        movement_scale = \
                get_viewport_rect().size.x / 2 \
                + container.size.x * container.scale.x / 2 \
                + pad
    elif direction in [ Vector2.UP, Vector2. DOWN ]:
        movement_scale = \
                get_viewport_rect().size.y / 2 \
                + container.size.y * container.scale.y / 2 \
                + pad

    var tween: Tween = create_tween()
    tween.tween_property(
            container, "position",
            direction * movement_scale,
            duration
    ).as_relative().from_current().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

    return tween
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

#region UI SFX listeners.
func _on_ui_container_slider_button_pressed():
    if _sfx_controller:
        _sfx_controller.play_sound("UISelectedSfx")


func _on_ui_scene_changer_button_pressed():
    if _sfx_controller:
        _sfx_controller.play_sound("UIAcceptedSfx")


func _on_ui_selected_button_pressed():
    if _sfx_controller:
        _sfx_controller.play_sound("UISelectedSfx")


func _on_ui_accepted_button_pressed():
    if _sfx_controller:
        _sfx_controller.play_sound("UIAcceptedSfx")


func _on_ui_disabled_button_pressed():
    if _sfx_controller:
        _sfx_controller.play_sound("UIRejectedSfx")
#endregion

#endregion
# ============================================================================ #
