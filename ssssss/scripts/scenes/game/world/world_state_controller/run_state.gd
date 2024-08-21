extends State


@export var world: World

var _started: bool
var _dead: bool

@onready var _start_cooldown_timer: Timer = $StartCooldownTimer
@onready var _step_timer: Timer = $StepTimer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _start_cooldown_timer.connect("timeout", _on_start_cooldown_timer_timeout)
    _step_timer.connect("timeout", _step)
#endregion
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    _started = false
    _dead = false
    _step_timer.paused = false
    _start_cooldown_timer.start()


func _exit() -> void:
    _step_timer.stop()


func _update(_delta: float, _game_state_data: Global.GameStateData) -> void:
    if _started:
        var snake_head: Vector2i = world.snake_head
        var snake_grid: WorldGrid2D = world.snake_grid
        if Input.is_action_just_pressed("p_move_up"):
            world.snake_grid.set_at(world.snake_head, Vector2i.UP)
        elif Input.is_action_just_pressed("p_move_down"):
            world.snake_grid.set_at(world.snake_head, Vector2i.DOWN)
        elif Input.is_action_just_pressed("p_move_left"):
            world.snake_grid.set_at(world.snake_head, Vector2i.LEFT)
        elif Input.is_action_just_pressed("p_move_right"):
            world.snake_grid.set_at(world.snake_head, Vector2i.RIGHT)

    if _dead:
        transitioned.emit(self, "StopState")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_snake() -> void:
    var grid: WorldGrid2D = world.snake_grid
    var current: Vector2i = world.snake_head
    var past_tail: bool = false
    while not past_tail:
        var movement = grid.get_at(current)
        var new_movement = grid.get_at(current + movement)
        if new_movement == grid.get_cell_default():
            world.snake_head += movement
            new_movement = movement
        elif current == world.snake_head:
            _dead = true
            return
        grid.set_at(current + movement, new_movement)

        current = current - movement
        if grid.get_at(current) != movement:
            grid.reset_at(current)
            past_tail = true
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _start_cooldown_timer.timeout().
func _on_start_cooldown_timer_timeout():
    _started = true
    _step_timer.start(0.1)


# Listens to _step_timer.timeout().
func _step() -> void:
    _update_snake()
#endregion
# ============================================================================ #
