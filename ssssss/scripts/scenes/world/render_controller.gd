@tool
extends Node


const SnakeDeath: PackedScene = preload("res://scenes/world/snake_death.tscn")

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
    if Engine.is_editor_hint():
        assert(world, "`world` must be set")
        assert(tile_map, "`tile_map` must be set")
        world.initialized.connect(_draw_editor_debug_layer)
        world.configuration_changed.connect(_draw_editor_debug_layer)
    else:
        world.built.connect(_draw_debug_layer)
        world.step.connect(_draw_debug_layer.unbind(1))
        world.built.connect(_draw_dynamic_layer)
        world.step.connect(_draw_dynamic_layer.unbind(1))
        world.snake_collided.connect(_on_snake_collided.unbind(1))


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

# Listens to world.snake_collided(snake_id: int, collide_coords: Vector2i).unbind(1).
func _on_snake_collided(snake_id: int) -> void:
    _play_snake_death_animation(snake_id)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils

## Undocumented. Used internally to render [AStar2D] instances during runtime
## for debugging.
func register_astar_debug_render(map: AStar2D) -> void:
    tile_map.get_node("DebugLayer/AStarVisualizer").load(map)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _draw_editor_debug_layer() -> void:
    var debug_layer: TileMapLayer = tile_map.get_node("DebugLayer")
    debug_layer.visible = world.draw_debug_grid
    if debug_layer.visible:
        debug_layer.clear()
        var debug_tileset_source_id: int = tile_map\
                .get_source_id("DebugLayer", "debug_tileset")
        var preview_player_snake: Array[Vector2i] = world.spawn_snake(
                Vector2i(world.player_spawn_x, world.player_spawn_y),
                Vector2i(Global.DIRECTIONS[world.player_spawn_direction]),
                world.player_initial_length,
                true
        )
        for x in range(Global.WORLD_SIZE.x):
            for y in range(Global.WORLD_SIZE.y):
                var cell_coords: Vector2i = Vector2i(x, y)
                var tile_name: StringName = \
                        tile_map.DEBUG_TILE_NAMES[(x + y) % 2]\
                        if cell_coords not in preview_player_snake\
                        else tile_map.DEBUG_TILE_NAMES[Vector2i(
                                Global.DIRECTIONS[world.player_spawn_direction]
                        )]
                debug_layer.set_cell(
                        cell_coords,
                        debug_tileset_source_id,
                        tile_map.get_tile_id(
                                debug_tileset_source_id,
                                tile_name
                        )["coords"]
                )


func _draw_debug_layer() -> void:
    var debug_layer: TileMapLayer = tile_map.get_node("DebugLayer")
    debug_layer.visible = world.draw_debug_grid
    if debug_layer.visible:
        debug_layer.clear()
        var debug_tileset_source_id: int = tile_map\
                .get_source_id("DebugLayer", "debug_tileset")
        for x in range(Global.WORLD_SIZE.x):
            for y in range(Global.WORLD_SIZE.y):
                var cell_coords: Vector2i = Vector2i(x, y)
                var snake_cell_data: Vector2i = world.snake_grid.get_at(cell_coords)
                var tile_name: StringName = \
                        tile_map.DEBUG_TILE_NAMES[(x + y) % 2]\
                        if snake_cell_data == world.snake_grid.get_cell_default()\
                        else tile_map.DEBUG_TILE_NAMES[snake_cell_data]

                debug_layer.set_cell(
                        cell_coords,
                        debug_tileset_source_id,
                        tile_map.get_tile_id(
                                debug_tileset_source_id,
                                tile_name
                        )["coords"]
                )


func _draw_dynamic_layer() -> void:
    var dynamic_layer: TileMapLayer = tile_map.get_node("DynamicLayer")
    dynamic_layer.clear()

    # Draw food.
    var food_tileset_source_id: int = tile_map.\
            get_source_id("DynamicLayer", "food_tileset")
    var food_grid: WorldGrid2D = world.food_grid
    for x in range(Global.WORLD_SIZE.x):
        for y in range(Global.WORLD_SIZE.y):
            var food_coords: Vector2i = Vector2i(x, y)
            if not food_grid.is_clear_at(food_coords):
                dynamic_layer.set_cell(
                        food_coords,
                        food_tileset_source_id,
                        tile_map.get_tile_id(
                                food_tileset_source_id,
                                tile_map.FOOD_TILE_NAMES[food_grid.get_at(food_coords)]
                        )["coords"]
                )

    # Draw snake.
    var is_world_odd_step: bool = world.step_count % 2 != 0
    var snake_tileset_source_id: int =\
            tile_map.get_source_id("DynamicLayer", "snake_odd_tileset")\
            if is_world_odd_step\
            else tile_map.get_source_id("DynamicLayer", "snake_even_tileset")
    var snakes: Array[Array] = world.snakes
    var snake_grid: WorldGrid2D = world.snake_grid
    for snake_id in range(snakes.size()):
        var is_primary_snake: bool = snake_id == 0
        var snake: Array[Vector2i] = snakes[snake_id]
        var snake_terrain_id: Dictionary
        if is_world_odd_step:
            snake_terrain_id = \
                    tile_map.get_terrain_id("DynamicLayer", "snake_odd_primary")\
                    if is_primary_snake\
                    else tile_map.get_terrain_id("DynamicLayer", "snake_odd_secondary")
        else:
            snake_terrain_id = \
                    tile_map.get_terrain_id("DynamicLayer", "snake_even_primary")\
                    if is_primary_snake\
                    else tile_map.get_terrain_id("DynamicLayer", "snake_even_secondary")

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
        dynamic_layer.set_cell(
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
                dynamic_layer.set_cell(
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
            splits.append(work_path.slice(split_begin, i + 1))
            split_begin = i - 1
    splits.append(work_path.slice(split_begin, work_path.size()))

    var dynamic_layer: TileMapLayer = tile_map.get_node("DynamicLayer")
    for i in range(splits.size()):
        var split: Array[Vector2i] = splits[i]

        var undershoot: bool = false
        undershoot = (
                split[0].distance_squared_to(split[1]) > 1
                and i > 0 # Tailward split cannot undershoot.
        )
        if undershoot:
            var diff: Vector2i = split[0] - split[1]
            split[0] -= diff + Vector2i(Vector2(diff).normalized())

        var overshoot: bool = false
        overshoot = (
                split[split.size() - 2].distance_squared_to(split[split.size() - 1]) > 1
                and i < splits.size() - 1 # Headward split cannot overshoot.
        )
        if overshoot:
            var diff: Vector2i = split[split.size() - 1] - split[split.size() - 2]
            split[split.size() - 1] -= diff + Vector2i(Vector2(diff).normalized())

        dynamic_layer.set_cells_terrain_path(
                split,
                terrain_set, terrain,
                ignore_empty_terrains
        )

        if undershoot:
            dynamic_layer.erase_cell(split[0])
        if overshoot:
            dynamic_layer.erase_cell(split[split.size() - 1])


func _play_snake_death_animation(snake_id: int) -> void:
    var snake_cell_coords: Array[Vector2i] = world.snakes[snake_id]
    for cell_coords in snake_cell_coords:
        var snake_death_sprite: Sprite2D = SnakeDeath.instantiate()
        snake_death_sprite.modulate =\
                Global.COLOR_PALETTE["fg_1"] if snake_id == 0\
                else Global.COLOR_PALETTE["fg_0"]
        snake_death_sprite.position = world.get_cell_position(cell_coords)
        tile_map.add_child(snake_death_sprite)
        await get_tree().create_timer(0.03).timeout

#endregion
# ============================================================================ #
