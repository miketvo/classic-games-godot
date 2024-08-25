extends GameScene2D


var _game_mode: Global.GameMode
var _paused: bool


@onready var _game_world: World = $World
@onready var _game_ui: UI = $UI/GameUI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _game_mode = Global.current_game_mode
    _paused = false
    _game_ui.acted.connect(_on_game_ui_acted)

    # TODO: Remove this test code:
    _game_world.initial_step_duration = Global.INITIAL_STEP_DURATION
    _game_world.food_eaten.connect(_on_food_eaten.unbind(1))
    # End of TODO.

    _game_world.stopped.connect(_on_game_over)


func _process(_delta: float) -> void:
    # TODO: Remove this test code:
    if _game_world.food_grid.is_clear():
        _game_world.spawn_random_food()
        _game_world.set_step_duration(
                _game_world.get_step_duration() * Global.STEP_DURATION_CHANGE
        )
    # End of TODO.
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func pause():
    _paused = true
    _game_world.pause()


func unpause():
    _paused = false
    _game_world.unpause()


func is_paused() -> bool:
    return _paused
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# TODO: Remove this test code:
func _on_food_eaten(snake_id: int) -> void:
    if snake_id == 0:
        _game_world.set_step_duration(
                _game_world.get_step_duration() * Global.STEP_DURATION_CHANGE
        )
# End of TODO.


func _on_game_over() -> void:
    _game_ui.game_over()


# Listens to $UI/GameUI.acted(action: StringName).
func _on_game_ui_acted(action: StringName) -> void:
    match action:
        "pause":
            pause()
        "resume":
            unpause()
        "restart":
            scene_finished.emit(SceneKey.GAME)
        "end_game":
            scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #
