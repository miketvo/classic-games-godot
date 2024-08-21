@tool
extends Node


const DEBUG_TILE_NAMES = {
    0: "_0",
    1: "_1",
    Vector2i.UP: "n",
    Vector2i.LEFT: "w",
    Vector2i.DOWN: "s",
    Vector2i.RIGHT: "e",
}

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


func _process(_delta: float) -> void:
    _draw_debug()
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
                var cell_id: Vector2i = Vector2i(x, y)
                var snake_cell_data: Vector2i = world.snake_grid.get_at(cell_id)
                var enemy_cell_data: Vector2i = world.enemy_grid.get_at(cell_id)

                var tile_name: StringName
                if snake_cell_data + enemy_cell_data == Vector2i.ZERO:
                    # Not a snake/enemy cell.
                    tile_name = DEBUG_TILE_NAMES[(x + y) % 2]
                else: # Is a snake/enemy cell.
                    tile_name = DEBUG_TILE_NAMES[snake_cell_data]\
                            if snake_cell_data != Vector2i.ZERO\
                            else DEBUG_TILE_NAMES[enemy_cell_data]

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
        var snake_tileset_source_id: int = tile_map.\
                get_source_id("EnvironmentLayer", "snake_tileset")
        var enemy_tileset_source_id: int = tile_map.\
                get_source_id("EnvironmentLayer", "enemy_tileset")
        var food_tileset_source_id: int = tile_map.\
                get_source_id("EnvironmentLayer", "food_tileset")

    for x in range(Global.WORLD_SIZE.x):
        for y in range(Global.WORLD_SIZE.y):
            pass  # TODO: Implement this.
#endregion
# ============================================================================ #
