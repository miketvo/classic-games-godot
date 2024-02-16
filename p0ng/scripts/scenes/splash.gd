extends GameScene2D


@onready var _animation_player: AnimationPlayer = get_node("Sprite2D/AnimationPlayer")


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _animation_player.connect("animation_finished", _end_splash.unbind(1))
    _animation_player.play("default")


func _process(_delta: float) -> void:
    if Input.is_action_pressed("skip"):
        _end_splash()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
## Listens to Sprite2D/AnimationPlayer.animation_finished(anim_name: String)
## unbind(1)
func _end_splash():
    _animation_player.stop(true)
    scene_finished.emit(SceneKey.NONE)
#endregion
# ============================================================================ #
