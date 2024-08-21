@tool
class_name World
extends Node2D


signal configuration_changed


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
@export_range(2, 2, 1, "or_greater") var player_initial_length: int = 3:
    set(value):
        player_initial_length = value
        configuration_changed.emit()


@export_group("Rendering", "draw")

## If [code]true[/code], the outline and direction (if applicable) of each cell
## is drawn.
@export var draw_debug_grid: bool = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Internal world state representation
@export_storage var snake_head: Vector2i
@export_storage var snake_grid: WorldGrid2D
@export_storage var enemy_heads: Array[Vector2i]
@export_storage var enemy_grid: WorldGrid2D
@export_storage var wall_grid: WorldGrid2D
@export_storage var food_grid: WorldGrid2D
#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    snake_head = Vector2i(-1, -1)
    snake_grid = WorldGrid2D.new(
            Global.WORLD_SIZE,
            TYPE_VECTOR2I, &"", null, [],
            true
    )
    enemy_heads = Array([], TYPE_VECTOR2I, &"", null)
    enemy_grid = WorldGrid2D.new(
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
#endregion
# ============================================================================ #
