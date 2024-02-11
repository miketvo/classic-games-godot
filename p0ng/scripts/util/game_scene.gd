extends Node2D


## Signal whether this scene is done processing and is ready to switch to the
## next scene.
signal scene_finished(next_scene_key: SceneKey)

enum SceneKey {
    SPLASH,
    MAIN_MENU,
}
