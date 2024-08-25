@tool
extends State


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
    world.configuration_changed.connect(_build_world)


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
#region State builtins
func _enter() -> void:
    _build_world()
    world.running = false
    if not Engine.is_editor_hint():
        transitioned.emit(self, "RunState")
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _build_world() -> void:
    world.snakes.clear()
    world.snake_grow_queue.clear()
    world.snake_grid.reset()
    world.wall_grid.reset()
    world.food_grid.reset()
    _load_walls()
    _spawn_player()


func _spawn_player() -> void:
    world.spawn_snake(
        Vector2i(world.player_spawn_x, world.player_spawn_y),
        Vector2i(Global.DIRECTIONS[world.player_spawn_direction]),
        world.player_initial_length
    )


func _load_walls() -> void:
    var static_layer := tile_map.get_node("StaticLayer") as TileMapLayer
    assert(static_layer, "StaticLayer not found")

    for x in range(Global.WORLD_SIZE.x):
        for y in range(Global.WORLD_SIZE.y):
            var cell_coords: Vector2i = Vector2i(x, y)
            var tile_data := static_layer.get_cell_tile_data(cell_coords)
            if tile_data:
                var tile_name := tile_data.get_custom_data("tile_name") as StringName
                if tile_name == tile_map.WALL_TILE_NAME:
                    world.wall_grid.set_at(cell_coords, true)
#endregion
# ============================================================================ #
