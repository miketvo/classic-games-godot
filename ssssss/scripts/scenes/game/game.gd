extends GameScene2D


signal level_loaded


enum GameResult {
    GAME_LOST,
    GAME_WON,
    NONE,
}


var game_world: World
var game_result: GameResult
var score: int
var food_respawn_cooldown: float
var kill_count: int

var _game_mode: Global.GameMode
var _level: Dictionary
var _level_scene: PackedScene
var _paused: bool

@onready var _game_ui: UI = $UI/GameUI
@onready var _game_stop_state: State = $GameStateController/StopState


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _game_mode = Global.current_game_mode
    _level = Global.levels[Global.current_level]
    _level_scene = load(_level["scene_file"])
    _paused = false

    _game_ui.acted.connect(_on_game_ui_acted)
    _game_stop_state.game_ended.connect(_on_game_ended)

    game_world = _level_scene.instantiate()
    game_world.initial_step_duration = Global.INITIAL_STEP_DURATION
    add_child(game_world)
    level_loaded.emit()

    game_result = GameResult.NONE
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func pause() -> void:
    _paused = true
    game_world.pause()


func unpause() -> void:
    _paused = false
    game_world.unpause()


func is_paused() -> bool:
    return _paused
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to $GameStateController/StopState.stopped().
func _on_game_ended() -> void:
    _game_ui.end_game()


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
