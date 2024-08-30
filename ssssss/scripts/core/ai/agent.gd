extends RefCounted


var _manual_controlled: bool


# ============================================================================ #
#region Godot builtins
func _init(manual_controlled: bool) -> void:
    _manual_controlled = manual_controlled
#endregion
# ============================================================================ #


# ============================================================================ #
#region Overriden methods

func start() -> void:
    pass


func get_action(_state: Global.GameStateData) -> Action:
    return Action.new()


func get_outcome(_action: Action, _state: Global.GameStateData) -> Global.GameOutcome:
    return Global.GameOutcome.WIN


func terminate() -> void:
    pass

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func is_manual_controlled() -> bool:
    return _manual_controlled
#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

class Action extends Object:
    pass

#endregion
# ============================================================================ #
