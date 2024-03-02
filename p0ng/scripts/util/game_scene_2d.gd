class_name GameScene2D
extends Node2D


## Signal whether this scene is done processing and is ready to switch to the
## next scene.
## [br][br]
## Not emitted by default. Must be emitted manually.
## [br][br]
## This signal is connected to [Main]. If [param next_scene_key] is used for the
## next scene change.
signal scene_finished(next_scene_key: SceneKey)

enum SceneKey {
    SPLASH,
    MAIN_MENU,
    SIDE_SELECT,
    GAME,
    NONE,
}

const GAME_SCENE = {
    SceneKey.SPLASH: "res://scenes/splash.tscn",
    SceneKey.MAIN_MENU: "res://scenes/main_menu/main_menu.tscn",
    SceneKey.SIDE_SELECT: "res://scenes/game/side_select.tscn",
    SceneKey.GAME: "res://scenes/game/game.tscn",
}
