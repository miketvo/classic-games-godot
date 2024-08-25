extends State


# ============================================================================ #
#region State builtins
func _enter() -> void:
    transitioned.emit(self, "BuildState") # TODO: Further implement the logic here.
#endregion
# ============================================================================ #
