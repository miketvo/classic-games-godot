extends State
## Classic mode game logic.


## For each multiple of this value, the number of random food being spawned in,
## will be increased by 1 (with minimum of 1 food respawned each time).
const FOOD_RESPAWN_COUNT_MULTIPLIER: int = 6
const MAX_FOOD_RESPAWN_COUNT: int = 3
const FOOD_RESPAWN_COOLDOWN: int = 6 ## Unit: steps.

## Unit: steps. Specifies the number of simulation steps before food will be
## respawned.
const FOOD_RESPAWN_DELAY_STEPS: int = 90


@export var game_scene: GameScene2D

var _world: World
var _food_pool: Array[Vector2i]
var _food_respawn_blocked: bool
var _food_respawn_count: int
var _target_score: int

@onready var _food_respawn_timer: Timer = $FoodRespawnTimer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(game_scene, "`game_scene` must be set")
    _food_pool = []
    _food_respawn_blocked = false
    _food_respawn_count = 0
    _food_respawn_timer.timeout.connect(_on_food_respawn_timer_timeout)
#endregion
# ============================================================================ #


# ============================================================================ #
#region State builtins
func _enter() -> void:
    _world = game_scene.game_world
    _world.paused.connect(_on_world_paused)
    _world.unpaused.connect(_on_world_unpaused)
    _world.stopped.connect(_lose_game)
    _world.food_eaten.connect(_on_food_eaten)
    _target_score = Global.levels[Global.current_level]\
            ["metadata"]["win_condition"]["classic_mode"]["target_score"]

    _food_pool.append(_world.spawn_random_food())
    _food_respawn_count += 1
    _food_respawn_timer.start(Global.INITIAL_STEP_DURATION * FOOD_RESPAWN_DELAY_STEPS)


func _update(_delta: float, _game_state_data: Global.GameStateData):
    game_scene.food_respawn_cooldown =\
            _food_respawn_timer.time_left / _food_respawn_timer.wait_time
    if game_scene.score >= _target_score:
        _win_game()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _world.paused().
func _on_world_paused() -> void:
    _food_respawn_timer.paused = true


# Listens to _world.unpaused().
func _on_world_unpaused() -> void:
    await get_tree().create_timer(_world.unpause_delay).timeout
    _food_respawn_timer.paused = false


# Listens to _world.food_eaten().
func _on_food_eaten(_snake_id: int, food_coords: Vector2i) -> void:
    game_scene.score += Global.FOOD_SCORE[_world.food_grid.get_at(food_coords)]
    _increase_game_speed()

    if not _food_respawn_blocked:
        # Add a cooldown before new food is respawned.
        _food_respawn_blocked = true
        _food_respawn_timer.paused = true
        await get_tree().create_timer(_world.get_step_duration() * FOOD_RESPAWN_COOLDOWN).timeout
        _food_respawn_blocked = false

        _respawn_food()
        _restart_food_respawn_timer()


# Listens to _food_respawn_timer.timeout().
func _on_food_respawn_timer_timeout() -> void:
    _respawn_food()
    _restart_food_respawn_timer()


#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _win_game() -> void:
    _food_respawn_timer.stop()
    _world.pause()
    game_scene.game_result = game_scene.GameResult.GAME_WON
    transitioned.emit(self, "StopState")


func _lose_game() -> void:
    _food_respawn_timer.stop()
    game_scene.game_result = game_scene.GameResult.GAME_LOST
    transitioned.emit(self, "StopState")


func _increase_game_speed() -> void:
    _world.set_step_duration(max(
            _world.get_step_duration() * Global.STEP_DURATION_CHANGE,
            Global.MIN_STEP_DURATION
    ))


func _respawn_food(except_coords: Vector2i = Vector2i(-1, -1)) -> void:
    var new_food_pool: Array[Vector2i] = []

    # Despawn old undigested food.
    for spawned_food_coords in _food_pool:
        if (
                spawned_food_coords != except_coords and
                _world.snake_grid.is_clear_at(spawned_food_coords)
        ): # If food is not at [param except_coords] or being digested.
            _world.despawn_food(spawned_food_coords)
        else: # If food is being digested.
            new_food_pool.append(spawned_food_coords)

    # Spawn in new food.
    @warning_ignore("integer_division")
    for i in range(min(
            _food_respawn_count / FOOD_RESPAWN_COUNT_MULTIPLIER + 1,
            MAX_FOOD_RESPAWN_COUNT
    )):
        new_food_pool.append(_world.spawn_random_food())

    _food_pool = new_food_pool
    _food_respawn_count += 1


func _restart_food_respawn_timer() -> void:
    _food_respawn_timer.stop()
    _food_respawn_timer.paused = false
    _food_respawn_timer.start(_world.get_step_duration() * FOOD_RESPAWN_DELAY_STEPS)
#endregion
# ============================================================================ #
