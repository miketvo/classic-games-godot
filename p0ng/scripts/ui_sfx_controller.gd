extends Node
## Controller for UI SFX.


func play(audio_stream_name: StringName):
    var audio_stream_player: AudioStreamPlayer = get_node("%s" % audio_stream_name)
    audio_stream_player.play()
