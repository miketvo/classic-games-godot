@tool
extends Node


@export var world: World:
    set(node):
        world = node
        update_configuration_warnings()

@export var tile_map: Node2D:
    set(node):
        tile_map = node
        update_configuration_warnings()


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(world, "`world` must be set")
    assert(tile_map, "`tile_map` must be set")
    world.connect("configuration_changed", _draw_debug)
    _draw_debug()
    if not Engine.is_editor_hint():
        world.get_node("WorldStateController/RunState/StepTimer")\
            .connect("timeout", _draw_debug)
        world.get_node("WorldStateController/RunState/StepTimer")\
            .connect("timeout", _draw_environment)
        _draw_environment()


func _get_configuration_warnings() -> PackedStringArray:
    var warnings = []

    if not world:
        warnings.append("`world` must be set.")

    if not tile_map:
        warnings.append("`tile_map` must be set.")
    else:
        var tile_map_children: Array[Node] = tile_map.get_children()
        var has_tile_map_layer: bool = false
        for child in tile_map_children:
            if child is TileMapLayer:
                has_tile_map_layer = true
                break
        if not has_tile_map_layer:
            warnings.append("`tile_map` must contain at least one TileMapLayer")

    return warnings
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _draw_debug() -> void:
    var debug_layer: TileMapLayer = tile_map.get_node("DebugLayer")
    debug_layer.visible = world.draw_debug_grid
    if debug_layer.visible:
        var debug_tileset_source_id: int = tile_map.get_source_id("DebugLayer", "debug_tileset")
        for x in range(Global.WORLD_SIZE.x):
            for y in range(Global.WORLD_SIZE.y):
                var cell_coords: Vector2i = Vector2i(x, y)
                var snake_cell_data: Vector2i = world.snake_grid.get_at(cell_coords)
                var tile_name: StringName = \
                        tile_map.DEBUG_TILE_NAMES[(x + y) % 2]\
                        if snake_cell_data == world.snake_grid.get_cell_default()\
                        else tile_map.DEBUG_TILE_NAMES[snake_cell_data]

                debug_layer.set_cell(
                        Vector2i(x, y),
                        debug_tileset_source_id,
                        tile_map.get_tile_id(
                                debug_tileset_source_id,
                                tile_name
                        )["coords"]
                )


func _draw_environment() -> void:
    if not Engine.is_editor_hint():
        var environment_layer: TileMapLayer = tile_map.get_node("EnvironmentLayer")
        environment_layer.clear()

        # Draw food.
        var food_tileset_source_id: int = tile_map.\
                get_source_id("EnvironmentLayer", "food_tileset")
        var food_grid: WorldGrid2D = world.food_grid
        for x in range(Global.WORLD_SIZE.x):
            for y in range(Global.WORLD_SIZE.y):
                var food_coords: Vector2i = Vector2i(x, y)
                if not food_grid.is_clear_at(food_coords):
                    environment_layer.set_cell(
                            food_coords,
                            food_tileset_source_id,
                            tile_map.get_tile_id(
                                    food_tileset_source_id,
                                    tile_map.FOOD_TILE_NAMES[food_grid.get_at(food_coords)]
                            )["coords"]
                    )

        # Draw snake.
        var snake_tileset_source_id: int = tile_map.\
                get_source_id("EnvironmentLayer", "snake_tileset")
        var snakes: Array[Array] = world.snakes
        var snake_grid: WorldGrid2D = world.snake_grid
        for snake_id in range(snakes.size()):
            var is_primary_snake: bool = snake_id == 0
            var snake: Array[Vector2i] = snakes[snake_id]
            var snake_terrain_id: Dictionary = \
                    tile_map.get_terrain_id("EnvironmentLayer", "snake_primary")\
                    if is_primary_snake\
                    else tile_map.get_terrain_id("EnvironmentLayer", "snake_secondary")

            # Snake body.
            _set_cells_terrain_path_wrapped(
                    snake,
                    snake_terrain_id["terrain_set"],
                    snake_terrain_id["terrain"]
            )

            # Snake head.
            var head_coords: Vector2i = snake[0]
            var head_direction: Vector2i = snake_grid.get_at(head_coords)
            var is_eating: bool = not food_grid.is_clear_at(head_coords)
            var snake_head_tile_name: StringName =\
                    tile_map.SNAKE_HEAD_TILE_NAMES[head_direction]
            if is_eating: snake_head_tile_name += "_eat"
            if is_primary_snake: snake_head_tile_name += "_primary"
            var head_tile_id: Dictionary = tile_map.get_tile_id(
                    snake_tileset_source_id,
                    snake_head_tile_name
            )
            environment_layer.set_cell(
                head_coords,
                snake_tileset_source_id,
                head_tile_id["coords"],
                head_tile_id["alt_id"]
            )

            # Snake body if digesting food.
            for cell_idx in range(1, snake.size() - 1):
                var body_coords: Vector2i = snake[cell_idx]
                var is_digesting: bool = not food_grid.is_clear_at(body_coords)
                var body_digest_tile_name: StringName =\
                        tile_map.SNAKE_BODY_EAT_TILE_NAME
                if is_primary_snake: body_digest_tile_name += "_primary"
                var body_digest_tile_id: Dictionary = tile_map.get_tile_id(
                        snake_tileset_source_id,
                        body_digest_tile_name
                )
                if is_digesting:
                    environment_layer.set_cell(
                        body_coords,
                        snake_tileset_source_id,
                        body_digest_tile_id["coords"],
                        body_digest_tile_id["alt_id"]
                    )


func _set_cells_terrain_path_wrapped(
        path: Array[Vector2i],
        terrain_set: int,
        terrain: int,
        ignore_empty_terrains: bool = true
) -> void:
    var work_path: Array[Vector2i] = path.duplicate()
    work_path.reverse()

    var splits: Array[Array] = []
    var split_begin: int = 0
    for i in range(1, work_path.size()):
        if work_path[i].distance_squared_to(work_path[i - 1]) > 1:
            splits.append(work_path.slice(split_begin, i))
            split_begin = i
    splits.append(work_path.slice(split_begin, work_path.size()))

    var environment_layer: TileMapLayer = tile_map.get_node("EnvironmentLayer")
    for i in range(splits.size()):
        var split: Array[Vector2i] = splits[i]

        var undershoot_cell: Vector2i = Vector2i(-1, -1)
        var overshoot_cell: Vector2i = Vector2i(-1, -1)
        if splits.size() > 0 and i > 0:
            undershoot_cell = splits[i - 1][splits[i - 1].size() - 1]
            var undershoot_diff: Vector2i = undershoot_cell - split[0]
            undershoot_cell -= (
                    undershoot_diff +
                    Vector2i(Vector2(undershoot_diff).normalized())
            )
            split.push_front(undershoot_cell)

            if i < splits.size() - 1:
                overshoot_cell = splits[i + 1][0]
                var overshoot_diff: Vector2i = overshoot_cell - split[split.size() - 1]
                overshoot_cell -= (
                        overshoot_diff +
                        Vector2i(Vector2(overshoot_diff).normalized())
                )
                split.push_back(overshoot_cell)

        environment_layer.set_cells_terrain_path(
                split,
                terrain_set,
                terrain,
                ignore_empty_terrains
        )

        if undershoot_cell != Vector2i(-1, -1):
            environment_layer.erase_cell(undershoot_cell)
        if overshoot_cell != Vector2i(-1, -1):
            environment_layer.erase_cell(overshoot_cell)
#endregion
# ============================================================================ #
