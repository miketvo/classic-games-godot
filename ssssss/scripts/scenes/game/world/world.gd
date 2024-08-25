@tool
class_name World
extends Node2D


signal configuration_changed
signal started
signal step(step_count: int)
signal snake_collided(snake_id: int, collide_coords: Vector2i)
signal food_eaten(snake_id: int, food_coords: Vector2i)
signal food_digested(snake_id: int, food_coords: Vector2i)
signal stopped


# ============================================================================ #
#region World configuration

@export_group("Player", "player")

## The x-coordinate of the player snake head.
@warning_ignore("integer_division")
@export_range(0, Global.WORLD_SIZE.x, 1) var player_spawn_x: int = Global.WORLD_SIZE.x / 2:
    set(value):
        player_spawn_x = value
        configuration_changed.emit()

## The y-coordinate of the player snake head.
@warning_ignore("integer_division")
@export_range(0, Global.WORLD_SIZE.y, 1) var player_spawn_y: int = Global.WORLD_SIZE.y / 2 - 2:
    set(value):
        player_spawn_y = value
        configuration_changed.emit()

## The direction that the player snake faces upon spawning.
@export var player_spawn_direction: Global.Direction = Global.Direction.UP:
    set(value):
        player_spawn_direction = value
        configuration_changed.emit()

## The initial length of the player snake upon spawning.
@warning_ignore("integer_division")
@export_range(2, mini(Global.WORLD_SIZE.x, Global.WORLD_SIZE.y) / 4, 1) var player_initial_length: int = 3:
    set(value):
        player_initial_length = value
        configuration_changed.emit()

@export_group("Simulation")
@export_range(0.01, 1.0, 0.001, "or_greater", "suffix:s") var initial_step_duration: float = 0.5

@export_group("Rendering", "draw")

## If [code]true[/code], the outline and direction (if applicable) of each cell
## is drawn.
@export var draw_debug_grid: bool = false:
    set(value):
        draw_debug_grid = value
        configuration_changed.emit()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## Whether the world is being simulated.
var running: bool

## The number of steps elapsed since the start of the world simulation,
## including the current step.
var step_count: int

#endregion
# ============================================================================ #


# ============================================================================ #
#region Internal world state representation
@export_storage var snakes: Array[Array]
@export_storage var snake_grow_queue: Array[int]
@export_storage var snake_grid: WorldGrid2D
@export_storage var wall_grid: WorldGrid2D
@export_storage var food_grid: WorldGrid2D
#endregion
# ============================================================================ #


@onready var _tile_map: Node2D = $TileMap
@onready var _run_state: State = $WorldStateController/RunState


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _tile_map.map_changed.connect(_on_tile_map_changed)
    _run_state.started.connect(_on_started)
    _run_state.step.connect(_on_step)
    _run_state.snake_collided.connect(_on_snake_collided)
    _run_state.food_eaten.connect(_on_food_eaten)
    _run_state.food_digested.connect(_on_food_digested)

    snakes = []
    snake_grow_queue = []
    snake_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_VECTOR2I, &"", null, [],
            true
    )
    wall_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_BOOL, &"", null, [],
            true
    )
    food_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_INT, &"", null, [],
            true
    )

    running = false
    step_count = 0
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func spawn_snake(spawn_coords: Vector2i, direction: Vector2i, length: int) -> void:
    var snake: Array[Vector2i] = []
    var current_position: Vector2i = spawn_coords
    for i in range(length):
        assert(
                snake_grid.is_clear_at(current_position),
                "Cannot spawn snake: (%d, %d) is occupied by another snake"
                % [current_position.x, current_position.y]
        )
        assert(
                wall_grid.is_clear_at(current_position),
                "Cannot spawn snake: (%d, %d) is occupied by a wall"
                % [current_position.x, current_position.y]
        )
        assert(
                food_grid.is_clear_at(current_position),
                "Cannot spawn snake: (%d, %d) is occupied by food"
                % [current_position.x, current_position.y]
        )
        snake.append(current_position)
        snake_grid.set_at(current_position, direction)
        current_position = snake_grid.wrap_coords(current_position - direction)
    snakes.append(snake)
    snake_grow_queue.append(0)


func despawn_snake(snake_id: int) -> void:
    snake_grow_queue.pop_at(snake_id)
    var snake := snakes.pop_at(snake_id) as Array[Vector2i]
    if snake:
        for cell_coords in snake:
            snake_grid.reset_at(cell_coords)


func spawn_food(spawn_coords: Vector2i, food_type: Global.FoodType) -> void:
    assert(
            snake_grid.is_clear_at(spawn_coords),
            "Cannot spawn food: (%d, %d) is occupied by a snake"
            % [spawn_coords.x, spawn_coords.y]
    )
    assert(
            wall_grid.is_clear_at(spawn_coords),
            "Cannot spawn food: (%d, %d) is occupied by a wall"
            % [spawn_coords.x, spawn_coords.y]
    )
    assert(
            food_grid.is_clear_at(spawn_coords),
            "Cannot spawn food: (%d, %d) is occupied by another food"
            % [spawn_coords.x, spawn_coords.y]
    )
    food_grid.set_at(spawn_coords, food_type)


func spawn_random_food(probabilities: Array[float] = Global.FOOD_PROBABILITIES) -> void:
    assert(
            probabilities.reduce(
                    func (accum, probability): return accum + probability
            ) == 1.0,
            "`probabilities` vector must add up to 1.0"
    )
    assert(
            probabilities.size() == Global.FoodType.size(),
            "`probabilities` vector size must match World.FoodType size"
    )

    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    var spawn_coords: Vector2i
    while true:
        spawn_coords = Vector2i(
                rng.randi_range(0, food_grid.size(Vector2i.AXIS_X)),
                rng.randi_range(0, food_grid.size(Vector2i.AXIS_Y))
        )
        if (
                food_grid.is_clear_at(spawn_coords) and
                wall_grid.is_clear_at(spawn_coords) and
                snake_grid.is_clear_at(spawn_coords)
        ): break
    var food_type: int = Global.FoodType.values()[rng.rand_weighted(probabilities)]
    spawn_food(spawn_coords, food_type)


func despawn_food(food_coords: Vector2i) -> void:
    food_grid.reset_at(food_coords)


func get_step_duration() -> float:
    return _run_state.get_step_duration()


func set_step_duration(duration: float) -> void:
    _run_state.set_step_duration(duration)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

func _on_started() -> void:
    running = true
    step_count = 1
    started.emit()


func _on_step() -> void:
    step_count += 1
    step.emit(step_count)


func _on_snake_collided(snake_id: int, collide_coords: Vector2i) -> void:
    despawn_snake(snake_id)
    snake_collided.emit(snake_id, collide_coords)


func _on_food_eaten(snake_id: int, food_coords: Vector2i) -> void:
    food_eaten.emit(snake_id, food_coords)


func _on_food_digested(snake_id: int, food_coords: Vector2i) -> void:
    # Queue snake growth based on food value if food is digested.
    snake_grow_queue[snake_id] += food_grid.get_at(food_coords)
    despawn_food(food_coords)
    food_digested.emit(snake_id, food_coords)


func _on_stopped() -> void:
    running = false
    step_count = 0
    stopped.emit()


# Listens to _tile_map.changed(layer_name: StringName)
func _on_tile_map_changed(layer_name: StringName) -> void:
    if layer_name == "StaticLayer":
        configuration_changed.emit()

#endregion
# ============================================================================ #
