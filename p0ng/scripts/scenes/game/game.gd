extends GameScene2D


const Ball: PackedScene = preload("res://scenes/game/ball.tscn")
const Padde: PackedScene = preload("res://scenes/game/paddle.tscn")

# @onready var _ball_spawn: Node2D = $Spawns/BallSpawn
# @onready var _left_paddle_spawn: Node2D = $Spawns/LeftPaddleSpawn
# @onready var _right_paddle_spawn: Node2D = $Spawns/RightPaddleSpawn


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    $UI/GameUI/PauseMenuContainer/EndGameButton\
            .connect("pressed", _on_end_game_request)


func _process(_delta: float) -> void:
    pass
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners
## Listens to $UI/GameUI/PauseMenuContainer/EndGameButton.pressed
func _on_end_game_request() -> void:
    scene_finished.emit(SceneKey.MAIN_MENU)
#endregion
# ============================================================================ #
