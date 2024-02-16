extends Control


const TRANS_DURATION: float = 0.5


func slide_transition(
    ui_element: Control,
    direction_vector: Vector2,
    duration: float
) -> void:
    if direction_vector not in Global.UNIT_VECTORS:
        assert(
                false,
                "MainMenuUI._slide_transition() "
                + "only accepts unit vector for `direction_vector`"
        )

    var tween = create_tween()
    tween.tween_property(
            ui_element, "position",
            direction_vector * (
                    get_viewport_rect().size.x / 2
                    + ui_element.size.x * ui_element.scale.x / 2
            ),
            duration
    ).as_relative().from_current().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
