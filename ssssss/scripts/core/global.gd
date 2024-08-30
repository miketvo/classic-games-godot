class_name NamespaceGlobal
extends Node2D


# ============================================================================ #
#region Enums

enum GameMode {
    CLASSIC,
    CHAOS,
}
enum GameOutcome {
    WIN,
    LOSE,
}
enum Direction {
    UP,
    LEFT,
    DOWN,
    RIGHT,
}

## The integer value on the RHS corresponds to how much a snake would grow when
## digesting the LHS food type.
enum FoodType {
    SMALL = 1,
    BIG = 10,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants
const LEVEL_DIRECTORY: String = "res://scenes/levels"
const LEVEL_PREVIEW_DIRECTORY: String = "res://assets/level_previews"
const LEVEL_PREVIEW_NULL: String = "res://assets/level_previews/null.png"
const COLOR_PALETTE: Dictionary = {
    "bg": Color("#180c21"),
    "fg_0": Color("#6f324e"),
    "fg_1": Color("#ce6b40"),
    "fg_2": Color("#fff4b0"),
}
const UNIT_VECTORS: PackedVector2Array = [
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
    Vector2.RIGHT,
]
const DIRECTIONS: Dictionary = {
    Direction.UP: Vector2.UP,
    Direction.LEFT: Vector2.LEFT,
    Direction.DOWN: Vector2.DOWN,
    Direction.RIGHT: Vector2.RIGHT,
}
const INITIAL_STEP_DURATION: float = 0.15 ## Unit: seconds.
const STEP_DURATION_CHANGE: float = 0.98 ## Affects how much the game speeds up. This is a ratio.
const MIN_STEP_DURATION: float = 0.06 ## Unit: seconds.
const WORLD_SIZE: Vector2i = Vector2i(60, 30) ## Unit: cells x cells.
const FOOD_PROBABILITIES: Array[float] = [0.8, 0.2] ## Must adds up to 1.0.
const FOOD_SCORE: Dictionary = { ## The score reward for the player for each food eaten.
    FoodType.SMALL: 50,
    FoodType.BIG: 100,
}
## The base score reward for the player when killing enemy snakes, based on how long that snake was.
const KILL_SCORE_PER_LENGTH: int = 150
# ============================================================================ #


# ============================================================================ #
#region Public variables

## The platform that the game is running on. Can be either
## [code]"Desktop"[/code], [code]"Mobile"[/code], or [code]"Web"[/code].
var os_platform: StringName

var software_cursor_visibility: SoftwareCursor.Visibility\
        = SoftwareCursor.Visibility.ALWAYS_VISIBLE
var levels: Array[Dictionary]
var current_level: int
var current_game_mode: GameMode
var game_state_data: GameStateData = GameStateData.new()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    var os_name: String = OS.get_name()
    match os_name:
        "Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
            os_platform = "Desktop"
        "Android", "iOS":
            os_platform = "Mobile"
        "Web":
            os_platform = "Web"
        _:
            printerr("Platform not supported: %s", os_name)
            get_tree().quit()

    levels = []


func _exit_tree() -> void:
    game_state_data.queue_free()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Game state data. Contains relevant information on the current state of the
## game, for use with a [StateMachine] and its [State]s.
class GameStateData extends Node:
    pass # TODO: Include game state data here for AI functionalities.

#endregion
# ============================================================================ #
