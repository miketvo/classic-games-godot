class_name SoftwareCursor
extends Sprite2D
## Software cursor


enum Visibility {
    ALWAYS_VISIBLE,
    IDLE_AUTO_HIDE,
    FORCE_HIDE
}


## Amount of time in seconds of mouse idling time before the cursor is hidden,
## if [member visibility] is set to
## [enum SoftwareCursor.Visibility.IDLE_AUTO_HIDE].
var idle_timeout: float = 1.0
var visibility: Visibility = Visibility.ALWAYS_VISIBLE


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    process_mode = Node.PROCESS_MODE_ALWAYS
    $IdleTimer.autostart = true
    $IdleTimer.connect("timeout", _on_idle_timer_timeout)


func _process(_delta: float) -> void:
    visibility = Global.software_cursor_visibility

    if visibility == Visibility.ALWAYS_VISIBLE and not visible:
        visible = true

    if visibility == Visibility.FORCE_HIDE and visible:
        visible = false

    if visible:
        position = get_viewport().get_mouse_position()
        var mouse_left_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
        var mouse_middle_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
        var mouse_right_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
        if mouse_left_clicked or mouse_middle_clicked or mouse_right_clicked:
            $AnimationPlayer.play("click")
            $AnimationPlayer.queue("idle")


func _input(event: InputEvent) -> void:
    if event is InputEventMouse:
        $IdleTimer.start(idle_timeout)
        if not visible:
            visible = true
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $IdleTimer.timeout().
func _on_idle_timer_timeout() -> void:
    if visibility == Visibility.IDLE_AUTO_HIDE:
        visible = false
#endregion
# ============================================================================ #
