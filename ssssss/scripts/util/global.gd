class_name NamespaceGlobal
extends Node2D


# ============================================================================ #
#region Enums
#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants
const UNIT_VECTORS: PackedVector2Array = [
    Vector2.UP,
    Vector2.LEFT,
    Vector2.DOWN,
    Vector2.RIGHT,
]
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## The platform that the game is running on. Can be either
## [code]"Desktop"[/code], [code]"Mobile"[/code], or [code]"Web"[/code].
var os_platform: StringName

var software_cursor_visibility: SoftwareCursor.Visibility\
        = SoftwareCursor.Visibility.ALWAYS_VISIBLE
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


func _exit_tree() -> void:
    game_state_data.queue_free()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func is_equal_approx(a: float, b: float, epsilon: float):
    return absf(a - b) < epsilon
#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Game state data. Contains relevant information on the current state of the
## game, for use with a [StateMachine] and its [State]s.
class GameStateData extends Node:
    pass
#endregion
# ============================================================================ #
