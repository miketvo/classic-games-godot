extends State


signal stopped


# ============================================================================ #
#region State builtins
func _enter() -> void:
    stopped.emit()
#endregion
# ============================================================================ #
