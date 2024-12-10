extends State


signal game_ended


# ============================================================================ #
#region State builtins
func _enter() -> void:
    game_ended.emit()
#endregion
# ============================================================================ #
