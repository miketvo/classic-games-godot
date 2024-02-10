extends Node2D


const SplashScene: PackedScene = preload("res://scenes/splash.tscn")


func _ready() -> void:
    pass


func _process(_delta: float) -> void:
    if not Global.splashed:
        if OS.is_debug_build():
            print_debug("Start splash.")

        Global.splashed = true
        get_tree().change_scene_to_packed(SplashScene)
