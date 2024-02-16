extends Control


const TRANS_DURATION: float = 0.5


func tween_transition_slide_container(
    container: Container,
    direction: Vector2,
    duration: float
) -> Tween:
    if direction not in Global.UNIT_VECTORS:
        assert(
                false,
                "UI.tween_transition_slide_container() "
                + "only accepts unit vector for `direction`"
        )

    var movement_scale: float
    if direction in [ Vector2.LEFT, Vector2.RIGHT ]:
        movement_scale = \
                get_viewport_rect().size.x / 2 \
                + container.size.x * container.scale.x / 2
    elif direction in [ Vector2.UP, Vector2. DOWN ]:
        movement_scale = \
                get_viewport_rect().size.y / 2 \
                + container.size.y * container.scale.y / 2

    var tween: Tween = create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(
            container, "position",
            direction * movement_scale,
            duration
    ).as_relative().from_current().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

    return tween
