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
    if _dead:
        transitioned.emit(self, "StopState")

    if _started:
        var new_direction: Vector2i = Vector2i.ZERO
        if Input.is_action_just_pressed("p_move_up"):
            new_direction = Vector2i.UP
        elif Input.is_action_just_pressed("p_move_down"):
            new_direction = Vector2i.DOWN
        elif Input.is_action_just_pressed("p_move_left"):
            new_direction = Vector2i.LEFT
        elif Input.is_action_just_pressed("p_move_right"):
            new_direction = Vector2i.RIGHT

        var snake_head: Vector2i = world.snake[0]
        var snake_grid: WorldGrid2D = world.snake_grid
        if (
                new_direction != Vector2i.ZERO and
                snake_head + new_direction != world.snake[1]
        ):
            world.snake_grid.set_at(snake_head, new_direction)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_snake() -> void:
    var snake_grid: WorldGrid2D = world.snake_grid
    var enemy_grid: WorldGrid2D = world.enemy_grid
    var wall_grid: WorldGrid2D = world.wall_grid
    for i in range(world.snake.size()):
        var movement = snake_grid.get_at(world.snake[i])
        var target_cell = world.snake[i] + movement
        var next_movement = snake_grid.get_at(target_cell)
        if i == 0:  # If this is the head of the snake.
            if (
                    snake_grid.is_clear_at(target_cell) and
                    enemy_grid.is_clear_at(target_cell) and
                    wall_grid.is_clear_at(target_cell)
            ):
                next_movement = movement
            else:
                _dead = true
                return

        snake_grid.set_at(target_cell, next_movement)
        if i == world.snake.size() - 1:
            snake_grid.reset_at(world.snake[i])
        world.snake[i] = target_cell
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
