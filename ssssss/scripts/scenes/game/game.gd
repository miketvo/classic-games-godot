extends GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    # TODO: Remove this test code:
    $World.initial_step_duration = Global.INITIAL_STEP_DURATION
    # End of TODO.


func _process(_delta: float) -> void:
    # TODO: Remove this test code:
    if $World.food_grid.is_clear():
        $World.spawn_random_food()
        $World.set_step_duration(
                $World.get_step_duration() * Global.STEP_DURATION_CHANGE
        )
    # End of TODO.
#endregion
# ============================================================================ #
