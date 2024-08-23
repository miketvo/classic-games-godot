extends State


# ============================================================================ #
#region State builtins
func _enter() -> void:
    transitioned.emit(self, "InitState") # TODO: Further implement the logic here.
#endregion
# ============================================================================ #
