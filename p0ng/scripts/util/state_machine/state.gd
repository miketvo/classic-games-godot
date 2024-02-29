class_name State
extends Node
## Represents a state in a state machine. Does not allow nesting of states. Must
## be a top-level child of a [StateMachine].


## Transitioning logic is implemented by the user by overriding the state's
## [method _update], [method _physics_update], [method _input_update],
## [method _unhandled_input_update], and [method _unhandled_key_input_update]
## methods. Should be emitted when a transition should occurs from
## [param from_state] to [param to_state_name].
## [br][br]
## [param from_state] should always be self. Otherwise the behavior of the
## [StateMachine] containing this state is undefined.
## [br][br]
## [param to_state_name] must be the [member Node.name] of a sibbling state to
## the current state, i.e. the next state must belong to the same [StateMachine]
## that the current state belongs to.
signal transitioned(from_state: State, to_state_name: StringName)


# ============================================================================ #
#region Godot builtins
func _enter_tree() -> void:
    if get_parent() is State:
        assert(false, "Nested States is not allowed")
    if not get_parent() is StateMachine:
        assert(false, "State must be a child of StateMachine")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Overriden methods

## Called when entering this state. Override this method to define custom
## behavior for state entry.
func _enter() -> void:
    pass


## Called when exiting this state. Override this method to define custom
## behavior for state exit.
func _exit() -> void:
    pass


## Called during the processing step of the main loop. Processing happens at
## every frame and as fast as possible. See [method Node._process].
## [br][br]
## Override this method to define custom frame update logic.
func _update(_delta: float, _game_state_data: Global.GameStateData) -> void:
    pass


## Called during the physics processing step of the main loop. Physics
## processing means that the frame rate is synced to the physics. See
## [method Node._physics_process].
## [br][br]
## Override this method to define custom physics frame update logic.
func _physics_update(_delta: float, _game_state_data: Global.GameStateData) -> void:
    pass


## Called when there is an input event. See [method Node._input].
## [br][br]
## Override this method to handle input specific to this state.
func _input_update(
        _event: InputEvent,
        _game_state_data: Global.GameStateData
) -> void:
    pass


## Called when an [InputEventKey] or [InputEventShortcut] hasn't been consumed
## by [method _input_update] or any GUI [Control] item. It is called before
## [method _unhandled_key_input_update] and [method _unhandled_input_update].
## See [Node._shortcut_input].
## [br][br]
## Override this method to handle shortcut input specific to this state.
func _shortcut_input_update(
        _event: InputEvent,
        _game_state_data: Global.GameStateData
) -> void:
    pass


## Called when an [InputEventKey] hasn't been consumed by [method _input_update]
## or any GUI [Control] item. It is called after [method _shortcut_input_update]
## but before [method _unhandled_input_update].
## [br][br]
## Override this method to handle unhandled key input specific to this state.
func _unhandled_key_input_update(
        _event: InputEvent,
        _game_state_data: Global.GameStateData
) -> void:
    pass


## Called when an [InputEvent] hasn't been consumed by [method _input_update] or
## any GUI [Control] item. It is called after [method _shortcut_input_update]
## and after [method _unhandled_key_input_update]. See
## [method Node._unhandled_input].
## [br][br]
## Override this method to handle unhandled input specific to this state.
func _unhandled_input_update(
        _event: InputEvent,
        _game_state_data: Global.GameStateData
) -> void:
    pass
#endregion
# ============================================================================ #
