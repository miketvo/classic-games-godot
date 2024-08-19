extends Node2D


## Shows the debug tilemap overlay.
@export var debug_grid: bool = false

var _snake_grid: WorldGrid2D
var _enemy_grid: WorldGrid2D
var _wall_grid: WorldGrid2D
var _food_grid: WorldGrid2D

@onready
var _tilemap: Node2D = %TileMap


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

    _debug_grid_setup()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _debug_grid_setup() -> void:
    var debug_layer: TileMapLayer = _tilemap.get_node("DebugLayer")
    for x in range(Global.WORLD_SIZE.x):
        for y in range(Global.WORLD_SIZE.y):
            debug_layer.set_cell(
                    Vector2i(x, y),
                    0, Vector2i((x + y) % 2, 0)
            )
    debug_layer.visible = debug_grid
#endregion
# ============================================================================ #
