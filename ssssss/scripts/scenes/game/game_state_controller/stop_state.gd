extends State


signal game_ended


# ============================================================================ #
#region State builtins
func _enter() -> void:
    Global.game_state_data.set_player_control_enabled(false)
    game_ended.emit()
#endregion
# ============================================================================ #
