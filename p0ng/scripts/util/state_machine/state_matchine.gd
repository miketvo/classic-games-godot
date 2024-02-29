class_name StateMachine
extends Node
## Implementation of finite state machine. Automatically recognizes children
## [States] and execute their logic. Has no effect if contain no [State] or if
## [member initial_state] is not set.
##
## @tutorial(Finite State Machine on Wikipedia): https://en.wikipedia.org/wiki/Finite-state_machine
## @tutorial(State Pattern on Wikipedia): https://en.wikipedia.org/wiki/State_pattern


## The starting state of this [StateMachine]. Must be one of its children
## [State].
@export var initial_state: State

var _current_state: State
var _states: Dictionary


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    var children = get_children()
    for child in children:
        if child is State:
            child.connect("transitioned", _on_child_state_transitioned)
            _states[child.name.to_lower()] = child
    if _states.is_empty():
        print_debug("State machine has no states")

    if not initial_state:
        print_debug("State machine has no initial state")
        return
    elif initial_state not in children:
        assert(false, "Unassociated initial state: %s" % initial_state.to_string())

    _current_state = initial_state
    _current_state._enter()


func _process(_delta: float) -> void:
    if _current_state:
        _current_state._update(_delta, Global.game_state_data)


func _physics_process(_delta: float) -> void:
    if _current_state:
        _current_state._physics_update(_delta, Global.game_state_data)


func _input(event: InputEvent) -> void:
    if _current_state:
        _current_state._input_update(event, Global.game_state_data)


func _shortcut_input(event: InputEvent) -> void:
    if _current_state:
        _current_state._shortcut_input_update(event, Global.game_state_data)


func _unhandled_key_input(event: InputEvent) -> void:
    if _current_state:
        _current_state._unhandled_key_input_update(event, Global.game_state_data)


func _unhandled_input(event: InputEvent) -> void:
    if _current_state:
        _current_state._unhandled_input_update(event, Global.game_state_data)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to children states' [signal State.transitioned].
func _on_child_state_transitioned(from_state: State, to_state_name: StringName) -> void:
    if from_state != _current_state:
        return

    var to_state: State = _states[to_state_name.to_lower()]
    if not to_state:
        assert(false, "State machine does not have state %s" % to_state_name)

    _current_state._exit()
    _current_state = to_state
    _current_state._enter()

#endregion
# ============================================================================ #
