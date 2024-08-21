extends State


# ============================================================================ #
#region State builtins
func _enter() -> void:
    transitioned.emit(self, "InitState")
#endregion
# ============================================================================ #
