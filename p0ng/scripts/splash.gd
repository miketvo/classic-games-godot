extends GameScene


@onready var _animation_player: AnimationPlayer = get_node("Sprite2D/AnimationPlayer")


func _ready() -> void:
    _animation_player.play("default")


func _process(_delta: float) -> void:
    if Input.is_action_pressed("skip"):
        end_splash()


func end_splash():
    _animation_player.stop(true)
    scene_finished.emit("")
