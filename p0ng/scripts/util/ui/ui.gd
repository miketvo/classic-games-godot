class_name UI
extends Control


signal acted(action: StringName)
signal acted_with_data(action: StringName, data: Variant)

const UI_TRANSITION_DURATION: float = 0.5

var input_disabled: bool = false

@onready var _sfx_controller: SfxController = get_tree().root.get_node("Main/UISfxController")


# ============================================================================ #
#region Godot builtins
func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Hides the [param control] and re-routes surrounding focus neighbor left, top,
## right, bottom, next, and previous.
## [br][br]
## This effectively quiet-remove the [param control] node from the [SceneTree],
## without affecting UI navigation behavior.
## [br][br]
## Intended for hiding desktop/web/mobile-only [Control]s. See
## [member NamespaceGlobal.os_platform].
static func deactivate_control(control: Control) -> void:
    var focus_links: Dictionary = {
        "left": control.get_node(control.focus_neighbor_left),
        "top": control.get_node(control.focus_neighbor_top),
        "right": control.get_node(control.focus_neighbor_right),
        "bottom": control.get_node(control.focus_neighbor_bottom),
        "next": control.get_node(control.focus_next),
        "previous": control.get_node(control.focus_previous),
    }

    focus_links.left.focus_neighbor_right = focus_links.left.get_path_to(focus_links.right)
    focus_links.right.focus_neighbor_left = focus_links.right.get_path_to(focus_links.left)
    focus_links.top.focus_neighbor_bottom = focus_links.top.get_path_to(focus_links.bottom)
    focus_links.bottom.focus_neighbor_top = focus_links.bottom.get_path_to(focus_links.top)
    focus_links.next.focus_previous = focus_links.next.get_path_to(focus_links.previous)
    focus_links.previous.focus_next = focus_links.previous.get_path_to(focus_links.next)
    control.hide()


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
        movement_scale = (
                get_viewport_rect().size.x / 2
                + container.size.x * container.scale.x / 2
                + pad
        )
    elif direction in [ Vector2.UP, Vector2. DOWN ]:
        movement_scale = (
                get_viewport_rect().size.y / 2
                + container.size.y * container.scale.y / 2
                + pad
        )

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

## Listens to tween transition Tween.finished() to re-enable input. Must be
## connected programmatically.
func _on_tween_transition_finshed() -> void:
    input_disabled = false


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
