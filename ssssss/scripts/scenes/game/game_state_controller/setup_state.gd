extends State
## Prepares the game scene.


@export var game_scene: GameScene2D


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(game_scene, "`game_scene` must be set")
#endregion
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    Global.game_state_data.set_player_control_enabled(true)
    await game_scene.level_loaded
    game_scene.score = 0
    match Global.current_game_mode:
        Global.GameMode.CLASSIC:
            game_scene.kill_count = -1
            transitioned.emit(self, "ClassicState")
        Global.GameMode.CHAOS:
            game_scene.kill_count = 0
            transitioned.emit(self, "ChaosState")
#endregion
# ============================================================================ #
