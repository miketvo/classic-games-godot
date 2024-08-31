class_name SnakeAgent
extends Object
## Base general AI agent class for all snakes. Extend this class and override
## [method _setup], [method _terminate], [method _get_action], and/or add more
## domain-specific methods (e.g. _get_outcome, _get_heuristic, etc.) to create
## more specific AI algorithms.
## [br][br]
## When constructing a new agent with [method SnakeAgent.new], the corresponding
## [code]snake_id[/code] must be provided. See [method SnakeAgent._init].


var _snake_id: int


# ============================================================================ #
#region Godot builtins

## Construct a [SnakeAgent] corresponding to the snake in [member World.snakes]
## with [param snake_id]. [b]Note:[/b] Do [b]NOT[/b] override this method. Use
## [method _setup] instead.
func _init(snake_id: int) -> void:
    _snake_id = snake_id
    _setup()


func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        _terminate()


## Override this method to customize the return value of
## [method Object.to_string], and therefore the [SnakeAgent] representation as a
## [String].
## [codeblock]
## class_name RandomSnakeAgent
## extends SnakeAgent
##
##
## func _start():
##     print(self)       # Prints "<RandomSnakeAgent{ snake_id: <some_int> }>"
##     var a = str(self) # a is "<RandomSnakeAgent{ snake_id: <some_int> }>"
##
##
## func _to_string() -> String:
##     var agent_class_name: String = get_script().get_global_name()
##     if agent_class_name.is_empty():
##         agent_class_name = get_class()
##     return "<%s{ snake_id: %d }>" % [
##         agent_class_name,
##         _snake_id
##     ]
## [/codeblock]
func _to_string() -> String:
    var agent_class_name: String = get_script().get_global_name()
    if agent_class_name.is_empty():
        agent_class_name = get_class()
    return "<%s{ snake_id: %d }>" % [
        agent_class_name,
        _snake_id
    ]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Overridable methods

## Called when the [SnakeAgent]. Override this method to define custom
## behavior for agent initialization/construction.
func _setup() -> void:
    pass


## Called every [World] step. Should return a [Global.Direction] action based
## on the world state in [param state]. Override this method to provide an
## algorithm to calculate the return value of [method get_action].
## [br][br]
## Do not call this method directly. Use [method get_action] instead.
## [br][br]
## [b]Note:[/b] This is an abstract method. It must be implemented in children
## classes.
func _get_action(_state: Global.GameStateData) -> Global.Direction:
    assert(false, "`_get_action` not implemented")
    @warning_ignore("int_as_enum_without_cast")
    @warning_ignore("int_as_enum_without_match")
    return -1


## Called when the [SnakeAgent] is freed from memory. Override this method to
## define custom behavior for agent clean-up/destruction.
func _terminate() -> void:
    pass

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [code]snake_id[/code] corresponds to the snake in
## [member World.snakes] being controlled by this [SnakeAgent].
func get_snake_id() -> int:
    return _snake_id


## Sets the [param snake_id].
func set_snake_id(snake_id: int) -> void:
    _snake_id = snake_id


## Returns the action based on the world state in [param state]. Override
## [method _get_action] to customize the action calculation algorithm.
func get_action(state: Global.GameStateData) -> Global.Direction:
    return _get_action(state)

#endregion
# ============================================================================ #
