extends GameScene2D


signal level_loaded
signal player_ate_food
signal player_killed_enemy
signal game_ended

enum GameResult {
    GAME_WON,
    GAME_LOST,
    NONE,
}

const GAME_END_DELAY: float = 1.6 ## Unit: seconds.

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

    _game_stop_state.game_ended.connect(_on_game_ended)
    _game_ui.acted.connect(_on_game_ui_acted)

    game_world = _level_scene.instantiate()
    game_world.initial_step_duration = Global.INITIAL_STEP_DURATION
    game_world.food_eaten.connect(_on_game_world_food_eaten.unbind(1))
    game_world.snake_collided.connect(_on_game_world_snake_collided)
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
    game_ended.emit()
    if game_result == GameResult.GAME_LOST:
        game_world.play_tile_map_animation("game_lost")

    # Give the player a bit of time to register the game result.
    await get_tree().create_timer(GAME_END_DELAY).timeout

    if game_result == GameResult.GAME_WON:
        game_world.play_tile_map_animation("game_won")
    _game_ui.end_game()


# Listens to $UI/GameUI.acted(action: StringName).
func _on_game_ui_acted(action: StringName) -> void:
    match action:
        "pause":
            pause()
        "resume":
            unpause()
        "next_level":
            Global.current_level += 1
            scene_finished.emit(SceneKey.GAME)
        "restart":
            scene_finished.emit(SceneKey.GAME)
        "end_game":
            scene_finished.emit(SceneKey.MAIN_MENU)


# Listens to _game_world.food_eaten(snake_id: int, food_coords: Vector2i).unbind(1).
func _on_game_world_food_eaten(snake_id: int) -> void:
    if snake_id == 0:
        player_ate_food.emit()


# Listens to _game_world.snake_collided(snake_id: int, food_coords: Vector2i).
func _on_game_world_snake_collided(snake_id: int, collide_coords: Vector2i) -> void:
    if (
            snake_id != 0 and
            collide_coords in game_world.snakes[0]
    ):
        player_killed_enemy.emit()

#endregion
# ============================================================================ #
