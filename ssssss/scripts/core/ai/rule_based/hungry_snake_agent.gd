class_name HungrySnakeAgent
extends SnakeAgent
## A [SnakeAgent] that always head for the closest food cell regardless of the
## food value, without regard to its own safety. Keep its current heading if no
## food cell is available.


const MapVisualizer: PackedScene = preload("res://scenes/world/a_star_2d_visualizer.tscn")


var _map_cache: SnakeAStar2D
var _id_path_cache: Array[int]
var _closest_food: Variant
static var _map_visualizer: AStar2DVisualizer
static var _agents_count: int = 0


# ============================================================================ #
#region SnakeAgent builtins
func _setup() -> void:
    _map_cache = null
    _id_path_cache = []
    _agents_count += 1


func _get_action(state: Global.GameStateData) -> Global.Direction:
    if state.get_tree().debug_collisions_hint and (not _map_visualizer):
        _map_visualizer = MapVisualizer.instantiate()
        state.world.get_node("TileMap").add_child(_map_visualizer)

    var snake_head: Vector2i = state.world.snakes[_snake_id][0]
    var new_closest_food: Variant = _get_closest_available_food(snake_head, state)
    if not new_closest_food:
        _closest_food = null
        return Global.Direction.NONE

    if not _map_cache:
        _construct_pathfinding_map(state)
    else:
        _update_pathfinding_map(state)
    if _map_visualizer:
        _map_visualizer.load_map(_map_cache)

    var target_point_id: Variant = null
    if _closest_food != new_closest_food:
        _closest_food = new_closest_food
        _id_path_cache = _get_id_path(snake_head, _closest_food)
        target_point_id = _id_path_cache.pop_front()
    else:
        var snake_grid: WorldGrid2D = state.world.snake_grid
        var valid_path: bool = true
        for point_id in _id_path_cache:
            var point_coords: Vector2i = Vector2i(_map_cache.get_point_position(point_id))
            if not snake_grid.is_clear_at(point_coords):
                valid_path = false
                break
        if not valid_path: _id_path_cache = _get_id_path(snake_head, _closest_food)
        target_point_id = _id_path_cache.pop_front()

    if target_point_id:
        var target_coords = _map_cache.get_point_position(target_point_id)
        var movement: Vector2 = target_coords - Vector2(snake_head)
        if (
                (
                        Vector2.UP.dot(movement.normalized()) == 0 # Horizontal
                        and movement.length_squared() == pow(Global.WORLD_SIZE.x, 2)
                ) != ( # XOR
                        Vector2.RIGHT.dot(movement.normalized()) == 0 # Vertical
                        and movement.length_squared() == pow(Global.WORLD_SIZE.y, 2)
                )
        ):
            movement = movement.normalized().rotated(PI)

        match Vector2i(movement):
            Vector2i.UP: return Global.Direction.UP
            Vector2i.LEFT: return Global.Direction.LEFT
            Vector2i.DOWN: return Global.Direction.DOWN
            Vector2i.RIGHT: return Global.Direction.RIGHT
            _:
                assert(
                        false,
                        "Invalid `target_coords`: (%d, %d)"
                        % [target_coords.x, target_coords.y]
                )
                return Global.Direction.NONE
    else:
        return Global.Direction.NONE


func _terminate():
    _agents_count -= 1
    if _agents_count == 0 and is_instance_valid(_map_visualizer):
        _map_visualizer.queue_free()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func get_map() -> SnakeAStar2D:
    return _map_cache


func get_map_id_path() -> Array[int]:
    return _id_path_cache.duplicate()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _construct_pathfinding_map(state: Global.GameStateData) -> void:
    var snake_head: Vector2i = state.world.snakes[_snake_id][0]
    var snake_grid: WorldGrid2D = state.world.snake_grid
    var wall_grid: WorldGrid2D = state.world.wall_grid

    _map_cache = SnakeAStar2D.new()
    _map_cache.reserve_space(Global.WORLD_SIZE.x * Global.WORLD_SIZE.y)

    # Add points.
    for y in range(Global.WORLD_SIZE.y):
        for x in range(Global.WORLD_SIZE.x):
            var coords: Vector2i = Vector2i(x, y)
            var point_id: int = x + y * Global.WORLD_SIZE.x
            if wall_grid.is_clear_at(coords):
                _map_cache.add_point(point_id, Vector2(coords))

    # Connect points and disable occupied points.
    for point_id in _map_cache.get_point_ids():
        var point_coords: Vector2i = Vector2i(_map_cache.get_point_position(point_id))

        # Connect surrounding points.
        var top_neighbor: Vector2i = snake_grid.wrap_coords(point_coords + Vector2i.UP)
        var top_neighbor_id: int = top_neighbor.x + top_neighbor.y * Global.WORLD_SIZE.x
        if _map_cache.has_point(top_neighbor_id):
            _map_cache.connect_points(point_id, top_neighbor_id)

        var left_neighbor: Vector2i = snake_grid.wrap_coords(point_coords + Vector2i.LEFT)
        var left_neighbor_id: int = left_neighbor.x + left_neighbor.y * Global.WORLD_SIZE.x
        if _map_cache.has_point(left_neighbor_id):
            _map_cache.connect_points(point_id, left_neighbor_id)

        var bottom_neighbor: Vector2i = snake_grid.wrap_coords(point_coords + Vector2i.DOWN)
        var bottom_neighbor_id: int = bottom_neighbor.x + bottom_neighbor.y * Global.WORLD_SIZE.x
        if _map_cache.has_point(bottom_neighbor_id):
            _map_cache.connect_points(point_id, bottom_neighbor_id)

        var right_neighbor: Vector2i = snake_grid.wrap_coords(point_coords + Vector2i.RIGHT)
        var right_neighbor_id: int = right_neighbor.x + right_neighbor.y * Global.WORLD_SIZE.x
        if _map_cache.has_point(right_neighbor_id):
            _map_cache.connect_points(point_id, right_neighbor_id)

        # Disable point if occupied.
        _map_cache.set_point_disabled(
                point_id,
                point_coords != snake_head and (not snake_grid.is_clear_at(point_coords))
        )


func _update_pathfinding_map(state: Global.GameStateData) -> void:
    var snake_head: Vector2i = state.world.snakes[_snake_id][0]
    var snake_grid: WorldGrid2D = state.world.snake_grid
    for point_id in _map_cache.get_point_ids():
        var coords: Vector2i = Vector2i(_map_cache.get_point_position(point_id))
        _map_cache.set_point_disabled(
                point_id,
                coords != snake_head and (not snake_grid.is_clear_at(coords))
        )


func _get_closest_available_food(from: Vector2i, state: Global.GameStateData) -> Variant:
    var snake_grid: WorldGrid2D = state.world.snake_grid
    var food_grid: WorldGrid2D = state.world.food_grid
    var food_pool: Array[Vector2i] = state.world.get_foods()
    if food_pool.is_empty(): return null

    var closest_food: Variant = null
    var distance: int = Global.WORLD_SIZE.length_squared()
    for food_coords in food_pool:
        if snake_grid.is_clear_at(food_coords):
            var new_distance: int = food_grid.l1_distance(from, food_coords)
            if new_distance < distance:
                distance = new_distance
                closest_food = food_coords
    return closest_food


func _get_id_path(from: Vector2i, to: Vector2i) -> Array[int]:
    var id_path: Array[int] = Array(Array(_map_cache.get_id_path(
            from.x + from.y * Global.WORLD_SIZE.x,
            to.x + to.y * Global.WORLD_SIZE.x
    )), TYPE_INT, &"", null)
    id_path.pop_front() # No need for the snake head to be in the path.
    return id_path
#endregion
# ============================================================================ #
