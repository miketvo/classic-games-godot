extends UI


@export var game_scene: GameScene2D

var _target_score: int
var _target_kills: int

@onready var _bound_rect: TextureRect = %BoundRect
@onready var _score_icon: TextureRect = %ScoreIcon
@onready var _score_label: Label = %ScoreLabel
@onready var _kill_icon: TextureRect = %KillIcon
@onready var _kill_count_label: Label = %KillCountLabel
@onready var _level_label: Label = %LevelLabel
@onready var _food_timeout_progress_bar: TextureProgressBar = %FoodTimeoutProgressBar


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(game_scene, "`game_scene` must be set")
    game_scene.player_ate_food.connect(_on_game_scene_player_ate_food)
    game_scene.player_killed_enemy.connect(_on_game_scene_player_killed_enemy)

    _level_label.text = "level %d: %s" % [
        Global.levels[Global.current_level]["metadata"]["order"],
        Global.levels[Global.current_level]["metadata"]["name"].to_upper(),
    ]

    match Global.current_game_mode:
        Global.GameMode.CLASSIC:
            _target_score = Global.levels[Global.current_level]\
                    ["metadata"]["win_condition"]["classic_mode"]["target_score"]
            _kill_icon.visible = false
            _kill_count_label.visible = false
            @warning_ignore("narrowing_conversion")
            _target_kills = NAN
        Global.GameMode.CHAOS:
            _target_score = Global.levels[Global.current_level]\
                    ["metadata"]["win_condition"]["chaos_mode"]["target_score"]
            _kill_icon.visible = true
            _kill_count_label.visible = true
            _target_kills = Global.levels[Global.current_level]\
                    ["metadata"]["win_condition"]["chaos_mode"]["target_kills"]
        _:
            assert(false, "Unrecognized game mode %d" % Global.current_game_mode)


func _process(_delta: float) -> void:
    _score_label.text = "%d/%d" % [game_scene.score, _target_score]
    if Global.current_game_mode == Global.GameMode.CHAOS:
        _kill_count_label.text = "%d/%d" % [game_scene.kill_count, _target_kills]
    _food_timeout_progress_bar.value =\
            _food_timeout_progress_bar.max_value * game_scene.food_respawn_cooldown
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to game_scene.player_ate_food().
func _on_game_scene_player_ate_food() -> void:
    _bound_rect.get_node("AnimationPlayer").play("active_food")
    _bound_rect.get_node("AnimationPlayer").queue("idle")
    _score_icon.get_node("AnimationPlayer").play("active")
    _score_icon.get_node("AnimationPlayer").queue("idle")


# Listens to game_scene.player_killed_enemy().
func _on_game_scene_player_killed_enemy() -> void:
    _bound_rect.get_node("AnimationPlayer").play("active_kill")
    _bound_rect.get_node("AnimationPlayer").queue("idle")
    _kill_icon.get_node("AnimationPlayer").play("active")
    _kill_icon.get_node("AnimationPlayer").queue("idle")

#endregion
# ============================================================================ #
