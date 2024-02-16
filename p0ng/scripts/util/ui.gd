extends Control


const TRANS_DURATION: float = 0.5


func slide_transition(
    ui_element: Container,
    direction: Vector2,
    duration: float
) -> void:
    if direction not in Global.UNIT_VECTORS:
        assert(
                false,
                "MainMenuUI._slide_transition() "
                + "only accepts unit vector for `direction`"
        )

    var movement_scale: float
    if direction in [ Vector2.LEFT, Vector2.RIGHT ]:
        movement_scale = \
                get_viewport_rect().size.x / 2 \
                + ui_element.size.x * ui_element.scale.x / 2
    elif direction in [ Vector2.UP, Vector2. DOWN ]:
        movement_scale = \
                get_viewport_rect().size.y / 2 \
                + ui_element.size.y * ui_element.scale.y / 2

    var tween = create_tween()
    tween.tween_property(
            ui_element, "position",
            direction * movement_scale,
            duration
    ).as_relative().from_current().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
