extends Sprite2D
## Software cursor


enum Visibility {
    ALWAYS_VISIBLE,
    IDLE_AUTO_HIDE,
    FORCE_HIDE
}


@export var visibility: Visibility

## Amount of time in seconds of mouse idling time before the cursor is hidden,
## if visibility is set to [enum Visibility.IDLE_AUTO_HIDE].
@export var idle_timeout: float

var _hidden: bool


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    process_mode = Node.PROCESS_MODE_ALWAYS
    _hidden = false


func _process(_delta: float) -> void:
    if visibility == Visibility.FORCE_HIDE and not _hidden:
        _hidden = true

    if visibility == Visibility.IDLE_AUTO_HIDE and not _hidden:
        _hidden = true

    if not _hidden:
        position = get_viewport().get_mouse_position()
        var mouse_left_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
        var mouse_middle_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
        var mouse_right_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
        if mouse_left_clicked or mouse_middle_clicked or mouse_right_clicked:
            $AnimationPlayer.play("click")
            $AnimationPlayer.queue("idle")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Getters & Setters
func get_visibility() -> Visibility:
    return visibility


func set_visibility(mode: Visibility) -> void:
    visibility = mode
#endregion
# ============================================================================ #
