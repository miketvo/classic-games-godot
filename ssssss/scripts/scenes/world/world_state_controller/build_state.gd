extends State


signal built

@export var world: World
@export var tile_map: Node2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(world, "`world` must be set")
    assert(tile_map, "`tile_map` must be set")
#endregion
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    await world.initialized
    _build_world()
    built.emit()
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


func _spawn_player() -> void:
    world.spawn_snake(
        Vector2i(world.player_spawn_x, world.player_spawn_y),
        Vector2i(Global.DIRECTIONS[world.player_spawn_direction]),
        world.player_initial_length,
        false, &"PlayerSnakeAgent"
    )
#endregion
# ============================================================================ #
