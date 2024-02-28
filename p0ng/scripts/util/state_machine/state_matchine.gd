class_name StateMachine
extends Node


@export var initial_state: State
var _current_state: State


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    if initial_state not in get_children():
        assert(false, "Unassociated state")

    _current_state = initial_state
    _current_state._enter()


func _process(_delta: float) -> void:
    _current_state._update(_delta)
    _transition_state()


func _physics_process(_delta: float) -> void:
    _current_state._physics_update(_delta)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Overriden methods
func _transition_state():
    pass
#endregion
# ============================================================================ #
