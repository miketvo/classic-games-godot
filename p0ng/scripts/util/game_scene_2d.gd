extends Node2D


## Signal whether this scene is done processing and is ready to switch to the
## next scene.
## [br][br]
## Not emitted by default. Must be emitted manually.
## [br][br]
## This signal is connected to [Main]. If [param next_scene_key] is
## [enum SceneKey.NONE], then the next scene is chosen by [Main]. Otherwise, it
## will be used for the next scene change.
signal scene_finished(next_scene_key: SceneKey)

enum SceneKey {
    SPLASH,
    MAIN_MENU,
    NONE,
}

const GAME_SCENE = {
    SceneKey.SPLASH: "res://scenes/splash.tscn",
    SceneKey.MAIN_MENU: "res://scenes/main_menu/main_menu.tscn",
}
