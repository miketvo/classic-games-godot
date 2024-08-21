extends State


@export var world: World

var _is_ready: bool

@onready var _start_delay_timer: Timer = $StartDelayTimer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _start_delay_timer.connect("timeout", func (): _is_ready = true)
#endregion
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    _is_ready = false
    _start_delay_timer.start()


func _update(_delta: float, _game_state_data: Global.GameStateData) -> void:
    if _is_ready:
        _update_snake()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_snake() -> void:
    var head: Vector2i = world.snake_head
    var grid: WorldGrid2D = world.snake_grid
    pass  # TODO: Implement this.
#endregion
# ============================================================================ #
