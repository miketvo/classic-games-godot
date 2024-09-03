extends State
## Chaos mode game logic.


## For each multiple of this value, the number of random food being spawned in,
## will be increased by 1 (with minimum of 1 food respawned each time).
const FOOD_RESPAWN_COUNT_MULTIPLIER: int = 6
const MAX_FOOD_RESPAWN_COUNT: int = 3
const FOOD_RESPAWN_COOLDOWN: int = 4 ## Unit: steps.

## Unit: steps. Specifies the number of simulation steps before food will be
## respawned.
const FOOD_RESPAWN_DELAY_STEPS: int = 90

const ENEMY_SPAWN_LENGTH: int = 3 ## Unit: cells.
const ENEMY_SPAWN_MIN_DELAY_STEPS: int = 20 ## Unit: steps.
const ENEMY_SPAWN_MAX_DELAY_STEPS: int = 60 ## Unit: steps.
const MAX_CONCURRENT_ENEMIES_COUNT: int = 2


@export var game_scene: GameScene2D

var _world: World
var _food_pool: Array[Vector2i]
var _food_respawn_blocked: bool
var _food_respawn_count: int
var _target_score: int
var _target_kills: int
var _rng: RandomNumberGenerator

@onready var _food_respawn_timer: Timer = $FoodRespawnTimer
@onready var _enemy_spawn_timer: Timer = $EnemySpawnTimer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(game_scene, "`game_scene` must be set")
    _food_pool = []
    _food_respawn_blocked = false
    _food_respawn_count = 0
    _food_respawn_timer.timeout.connect(_on_food_respawn_timer_timeout)
    _enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
    _rng = RandomNumberGenerator.new()
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
    _world.snake_collided.connect(_on_snake_collided)

    _target_score = Global.levels[Global.current_level]\
            ["metadata"]["win_condition"]["chaos_mode"]["target_score"]
    _target_kills = Global.levels[Global.current_level]\
            ["metadata"]["win_condition"]["chaos_mode"]["target_kills"]

    _food_pool.append(_world.spawn_random_food())
    _food_respawn_count += 1
    _food_respawn_timer.start(Global.INITIAL_STEP_DURATION * FOOD_RESPAWN_DELAY_STEPS)
    _enemy_spawn_timer.start(Global.INITIAL_STEP_DURATION * ENEMY_SPAWN_MIN_DELAY_STEPS)


func _update(_delta: float, _game_state_data: Global.GameStateData):
    game_scene.food_respawn_cooldown =\
            _food_respawn_timer.time_left / _food_respawn_timer.wait_time

    if (
        game_scene.score >= _target_score and
        game_scene.kill_count >= _target_kills
    ):
        _win_game()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _world.paused().
func _on_world_paused() -> void:
    Global.game_state_data.set_player_control_enabled(false)
    _food_respawn_timer.paused = true


# Listens to _world.unpaused().
func _on_world_unpaused() -> void:
    Global.game_state_data.set_player_control_enabled(true)
    await get_tree().create_timer(_world.unpause_delay).timeout
    _food_respawn_timer.paused = false


# Listens to _world.food_eaten(snake_id: int, food_coords: Vector2i).
func _on_food_eaten(snake_id: int, food_coords: Vector2i) -> void:
    if snake_id == 0:
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


# Listens to _world.snake_collided(snake_id: int, collide_coords: Vector2i).
func _on_snake_collided(snake_id: int, collide_corrds: Vector2i) -> void:
    if snake_id > 0 and collide_corrds in _world.snakes[0]:
        game_scene.kill_count += 1
        game_scene.score += (
                _world.snakes[snake_id].size() *
                Global.KILL_SCORE_PER_LENGTH
        )


# Listens to _enemy_spawn_timer.timeout().
func _on_enemy_spawn_timer_timeout() -> void:
    if _world.snakes.size() <= MAX_CONCURRENT_ENEMIES_COUNT:
        _spawn_random_enemy()
        _restart_enemy_spawn_timer()

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


func _spawn_random_enemy() -> void:
    var snake_grid: WorldGrid2D = _world.snake_grid
    var wall_grid: WorldGrid2D = _world.wall_grid
    var food_grid: WorldGrid2D = _world.food_grid

    var spawn_direction: Vector2i
    while true:
        spawn_direction = Global.DIRECTIONS[randi_range(0, Global.Direction.values().size() - 1)]
        if spawn_direction != Global.DIRECTIONS[Global.Direction.NONE]: break

    var is_clear: bool = false
    var spawn_coords: Vector2i
    while not is_clear:
        is_clear = true
        spawn_coords = Vector2i(
                _rng.randi_range(0, snake_grid.size(Vector2i.AXIS_X) - 1),
                _rng.randi_range(0, snake_grid.size(Vector2i.AXIS_Y) - 1)
        )

        var test_snake: Array[Vector2i] = _world.spawn_snake(
                spawn_coords, spawn_direction, ENEMY_SPAWN_LENGTH,
                true
        )
        for test_coords in test_snake:
            if (
                    not food_grid.is_clear_at(test_coords) or
                    not wall_grid.is_clear_at(test_coords) or
                    not snake_grid.is_clear_at(test_coords)
            ):
                is_clear = false
                break
    _world.spawn_snake(
            spawn_coords, spawn_direction, ENEMY_SPAWN_LENGTH,
            false, &"HungrySnakeAgent"
    )


func _restart_enemy_spawn_timer() -> void:
    _enemy_spawn_timer.stop()
    _enemy_spawn_timer.paused = false
    _enemy_spawn_timer.start(
            _world.get_step_duration() * _rng.randi_range(
                    ENEMY_SPAWN_MIN_DELAY_STEPS,
                    ENEMY_SPAWN_MAX_DELAY_STEPS
            )
    )
#endregion
# ============================================================================ #
