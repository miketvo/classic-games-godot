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

    world.connect("configuration_changed", _build_world)
    tile_map.connect("map_changed", _build_world)
    _build_world()
    if Engine.is_editor_hint():
        transitioned.emit(self, "RunState")


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
func _build_world() -> void:
    world.snake_grid.reset()
    world.enemy_heads.clear()
    world.enemy_grid.reset()
    world.wall_grid.reset()
    world.food_grid.reset()

    _spawn_player()
    print("Built world")


func _spawn_player() -> void:
    world.snake_head = Vector2i(world.player_spawn_x, world.player_spawn_y)
    var current_position: Vector2i = world.snake_head
    var direction: Vector2i = Vector2i(Global.DIRECTIONS[world.player_spawn_direction])
    for i in range(world.player_initial_length):
        world.snake_grid.set_at(current_position, direction)
        current_position = (current_position - direction) % Global.WORLD_SIZE

#endregion
# ============================================================================ #
