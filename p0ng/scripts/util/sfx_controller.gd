extends Node
## Controller for UI SFX.


func play_sound(audio_stream_name: StringName):
    var audio_stream_player: AudioStreamPlayer = get_node("%s" % audio_stream_name)
    audio_stream_player.play()


func play_sound2d(audio_stream_name: StringName, position: Vector2):
    var audio_stream_player: AudioStreamPlayer2D = get_node("%s" % audio_stream_name)
    audio_stream_player.global_position = position
    audio_stream_player.play()
