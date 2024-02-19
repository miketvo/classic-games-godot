extends Sprite2D
## Software cursor


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
    position = get_viewport().get_mouse_position()
    var mouse_left_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
    var mouse_middle_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
    var mouse_right_clicked: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
    if mouse_left_clicked or mouse_middle_clicked or mouse_right_clicked:
        $AnimationPlayer.play("click")
        $AnimationPlayer.queue("idle")
