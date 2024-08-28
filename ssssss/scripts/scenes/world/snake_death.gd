extends Sprite2D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _animation_player.play("death")
    _animation_player.animation_finished.connect(_on_animation_finished.unbind(1))
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _animation_player.animation_finished(anim_name: StringName).unbind(1).
func _on_animation_finished() -> void:
    self.queue_free()
#endregion
# ============================================================================ #
