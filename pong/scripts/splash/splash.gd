extends Node2D


const NEXT_SCENE_PATH: String = "res://scenes/main.tscn"
@onready var _animation_player: AnimationPlayer = get_node("Sprite2D/AnimationPlayer")


func _ready() -> void:
    _animation_player.play("default")


func _process(_delta: float) -> void:
    if Input.is_action_pressed("skip"):
        end_splash()


func end_splash():
    if OS.is_debug_build():
        print_debug("End splash.")

    _animation_player.stop(true)
    get_tree().change_scene_to_file(NEXT_SCENE_PATH)
