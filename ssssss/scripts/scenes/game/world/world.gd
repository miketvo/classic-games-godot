@tool
class_name World
extends Node2D


signal configuration_changed
@warning_ignore("unused_signal")
signal collided(snake_id: int, position: Vector2i)
@warning_ignore("unused_signal")
signal food_digested(snake_id: int)


# ============================================================================ #
#region Enums
enum FoodType {
    SMALL = 1,
    BIG = 2
}
#endregion
# ============================================================================ #


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
@warning_ignore("integer_division")
@export_range(2, mini(Global.WORLD_SIZE.x, Global.WORLD_SIZE.y) / 4, 1) var player_initial_length: int = 3:
    set(value):
        player_initial_length = value
        configuration_changed.emit()


@export_group("Rendering", "draw")

## If [code]true[/code], the outline and direction (if applicable) of each cell
## is drawn.
@export var draw_debug_grid: bool = false:
    set(value):
        draw_debug_grid = value
        configuration_changed.emit()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## The number of steps elapsed since the start of the world simulation,
## including the current step.
var step_count: int

#endregion
# ============================================================================ #


# ============================================================================ #
#region Internal world state representation
@export_storage var snakes: Array[Array]
@export_storage var snake_grid: WorldGrid2D
@export_storage var wall_grid: WorldGrid2D
@export_storage var food_grid: WorldGrid2D
#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    snakes = Array([], TYPE_ARRAY, &"", null)
    snake_grid = WorldGrid2D.new(
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


# ============================================================================ #
#region Public methods
func spawn_snake(position: Vector2i, direction: Vector2i, length: int):
    pass


func despawn_snake(snake_id: int):
    pass


func grow_snake(snake_id: int):
    pass


func spawn_food(position: Vector2i, food_type: FoodType):
    pass


func spawn_random_food():
    pass


func despawn_food(position: Vector2i):
    pass
#endregion
# ============================================================================ #
