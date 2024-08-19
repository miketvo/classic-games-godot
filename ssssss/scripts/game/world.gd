extends Node2D


## Shows the debug tilemap overlay.
@export var debug_grid: bool = false

var _snake_grid: WorldGrid2D
var _food_grid: WorldGrid2D
var _wall_grid: WorldGrid2D
var _enemy_grid: WorldGrid2D

@onready
var _tilemap: TileMap = %TileMap


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _snake_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_VECTOR2I, &"", null, [],
            true
    )
    _food_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_INT, &"", null, [],
            true
    )
    _wall_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_BOOL, &"", null, [],
            true
    )
    _enemy_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_VECTOR2I, &"", null, [],
            true
    )

    if debug_grid:
        _debug_grid_setup()
        _tilemap.set_layer_enabled(0, debug_grid)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _debug_grid_setup() -> void:
    for x in range(Global.WORLD_SIZE.x):
        for y in range(Global.WORLD_SIZE.y):
            _tilemap.set_cell(
                    0, Vector2i(x, y),
                    1, Vector2i((x + y) % 2, 0)
            )
#endregion
# ============================================================================ #
