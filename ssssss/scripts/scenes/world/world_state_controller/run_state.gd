extends State


signal started
signal step
signal snake_collided(snake_id: int, collide_coords: Vector2i)
signal food_eaten(snake_id: int, food_coords: Vector2i)
signal food_digested(snake_id: int, food_coords: Vector2i)


@export var world: World

var _started: bool
var _dead: bool
var _next_step_duration: float

@onready var _start_cooldown_timer: Timer = $StartCooldownTimer
@onready var _step_timer: Timer = $StepTimer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _start_cooldown_timer.timeout.connect(_on_start_cooldown_timer_timeout)
    _step_timer.timeout.connect(_step)
#endregion
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    _started = false
    _dead = false
    _start_cooldown_timer.paused = false
    _start_cooldown_timer.start(world.start_delay)


func _update(_delta: float, _game_state_data: Global.GameStateData) -> void:
    if _dead:
        _step_timer.stop()
        transitioned.emit(self, "StopState")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the step duration (in seconds).
func get_step_duration() -> float:
    return $StepTimer.wait_time


## Sets the step [param duration] (in seconds). Can be used to increase or
## decrease the world simulation speed.
func set_step_duration(duration: float) -> void:
    _next_step_duration = duration


func pause() -> void:
    _step_timer.paused = true


func unpause() -> void:
    await get_tree().create_timer(world.unpause_delay).timeout
    _step_timer.paused = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _start_cooldown_timer.timeout().
func _on_start_cooldown_timer_timeout() -> void:
    _started = true
    _next_step_duration = world.initial_step_duration
    _step_timer.paused = false
    _step_timer.start(_next_step_duration)
    started.emit()


# Listens to _step_timer.timeout().
func _step() -> void:
    _update_snake_heads()
    _update_snakes()
    if _next_step_duration != _step_timer.wait_time:
        _step_timer.stop()
        _step_timer.paused = false
        _step_timer.start(_next_step_duration)
    step.emit()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _update_snake_heads() -> void:
    var snake_agents: Array[SnakeAgent] = world.snake_agents
    var snake_grid: WorldGrid2D = world.snake_grid
    for snake_id in range(world.snakes.size()):
        var snake_head: Vector2i = world.snakes[snake_id][0]
        var snake_agent: SnakeAgent = snake_agents[snake_id]
        if snake_agent:
            var next_movement = Vector2i(
                    Global.DIRECTIONS[snake_agent.get_action(Global.game_state_data)]
            )
            if next_movement != Global.DIRECTIONS[Global.Direction.NONE]:
                # Change direction if agent action is not NONE.
                snake_grid.set_at(snake_head, next_movement)


func _update_snakes() -> void:
    var snake_grid: WorldGrid2D = world.snake_grid
    var wall_grid: WorldGrid2D = world.wall_grid
    var food_grid: WorldGrid2D = world.food_grid

    for snake_id in range(world.snakes.size()):
        var is_primary_snake: bool = snake_id == 0
        var snake: Array[Vector2i] = world.snakes[snake_id]
        var snake_grow_queue: Array[int] = world.snake_grow_queue
        for cell_idx in range(snake.size()):
            var cell_coords: Vector2i = snake[cell_idx]
            var movement: Vector2i = snake_grid.get_at(cell_coords)
            var target_cell: Vector2i = snake_grid.wrap_coords(cell_coords + movement)
            var next_movement: Vector2i = snake_grid.get_at(target_cell)
            if cell_idx == 0: # Head update.
                # Collision detection at the snake's head.
                if (
                        snake_grid.is_clear_at(target_cell) and
                        wall_grid.is_clear_at(target_cell)
                ):
                    next_movement = movement
                else:
                    snake_collided.emit(snake_id, target_cell)
                    # Stop the simulation if the primary snake is dead.
                    if is_primary_snake: _dead = true
                    break

                # Food detection at the snake's head.
                if not food_grid.is_clear_at(target_cell):
                    food_eaten.emit(snake_id, target_cell)

            snake_grid.set_at(target_cell, next_movement)
            if cell_idx == snake.size() - 1: # Tail update.
                if not food_grid.is_clear_at(cell_coords):
                    food_digested.emit(snake_id, cell_coords)

                # Grow the snake if the grow queue is not empty.
                if snake_grow_queue[snake_id] > 0:
                    snake.append(cell_coords)
                    snake_grow_queue[snake_id] -= 1
                else:
                    snake_grid.reset_at(cell_coords)
            snake[cell_idx] = target_cell
#endregion
# ============================================================================ #
