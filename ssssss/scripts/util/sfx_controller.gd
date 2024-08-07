@icon("res://assets/icons/sfx_controller.svg")
class_name SfxController
extends Node
## Simple controller for UI SFX. All children nodes must be either
## [AudioStreamPlayer] or [AudioStreamPlayer2D].


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    var children: Array[Node] = get_children()
    if children.size() == 0:
        return

    for child in children:
        assert(
                (child is AudioStreamPlayer) or (child is AudioStreamPlayer2D),
                "SfxController must contain only AudioStreamPlayer or AudioStreamPlayer2D"
        )
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Plays a child [AudioStreamPlayer].
func play_sound(audio_stream_name: StringName):
    var audio_stream_player: AudioStreamPlayer = get_node("%s" % audio_stream_name)
    audio_stream_player.play()


## Plays a child [AudioStreamPlayer2D].
func play_sound2d(audio_stream_name: StringName, position: Vector2):
    var audio_stream_player: AudioStreamPlayer2D = get_node("%s" % audio_stream_name)
    audio_stream_player.global_position = position
    audio_stream_player.play()

#endregion
# ============================================================================ #
