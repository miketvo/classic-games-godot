extends GameScene2D


signal load_succeeded
signal load_failed


@onready var _ui: UI = $UI/LevelSelectUI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    _ui.acted.connect(_on_ui_acted)
    _ui.acted_with_data.connect(_on_ui_acted_with_data)

    if Global.levels.is_empty():
        var error: Error = _load_level_scenes()
        if error == OK:
            load_succeeded.emit()
        else:
            load_failed.emit()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _ui.acted(action: StringName).
func _on_ui_acted(action: StringName) -> void:
    match action:
        "back_to_main_menu":
            scene_finished.emit(SceneKey.MAIN_MENU)


# Listens to _ui.acted_with_data(action: StringName, data: Variant).
func _on_ui_acted_with_data(action: StringName, data: Variant) -> void:
    match action:
        "play_game":
            Global.current_level = data
            scene_finished.emit(SceneKey.GAME)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _load_level_scenes() -> Error:
    var level_dir: DirAccess = DirAccess.open(Global.LEVEL_DIRECTORY)
    var level_dir_list: Array[String] = Array(
            Array(level_dir.get_files()),
            TYPE_STRING, &"", null
    )
    if level_dir_list.is_empty():
        printerr("No levels available in %s", Global.LEVEL_DIRECTORY)
        return FAILED

    var level_metadata_files: Array[String] = level_dir_list.filter(
            func (file_name: String): return (file_name.ends_with(".json"))
    )
    var level_scene_files = level_dir_list.filter(
            func (file_name: String): return (
                    file_name.ends_with(".tscn") or file_name.ends_with(".scn")
            )
    )

    var level_keys: Array[String] = Array(level_metadata_files.map(
            func (key: String): return key.get_basename()
    ), TYPE_STRING, &"", null)
    var level_keys_verify: Array[String] = Array(level_scene_files.map(
            func (key: String): return key.get_basename()
    ), TYPE_STRING, &"", null)
    if level_keys != level_keys_verify:
        printerr("Failed to open level metadata: file mismatch")
        return FAILED

    var level_metadata: Array[Dictionary] = []
    for level_metadata_file in level_metadata_files:
        var file_path: String = Global.LEVEL_DIRECTORY.path_join(level_metadata_file)
        var data := _load_metadata_file(file_path) as Dictionary
        if not data: return FAILED
        level_metadata.append(data)

    for i in range(level_keys.size()):
        var level_dict: Dictionary = {}
        level_metadata[i]["preview"] = Global.LEVEL_PREVIEW_DIRECTORY\
                .path_join(level_metadata[i]["preview"])
        level_metadata[i].make_read_only()
        level_dict["metadata"] = level_metadata[i]
        level_dict["scene_file"] = Global.LEVEL_DIRECTORY.path_join(level_scene_files[i])

        level_dict.make_read_only()
        Global.levels.append(level_dict)

    Global.levels.sort_custom(
            func (
                    a: Dictionary,
                    b: Dictionary
            ): return a["metadata"]["order"] < b["metadata"]["order"]
    )
    Global.levels.make_read_only()
    return OK


func _load_metadata_file(file_path: String) -> Variant:
    var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        var open_error: Error = FileAccess.get_open_error()
        printerr(
                "Failed to open level metadata in %s (%d: %s)"
                % [file_path, open_error, error_string(open_error)]
        )
        return null
    var data: String = file.get_as_text()
    var json: JSON = JSON.new()
    var read_error: Error = json.parse(data)
    if read_error != OK:
        printerr(
                "Failed to read level metadata in %s"
                % [file_path, read_error, error_string(read_error)]
        )
        return null
    return json.data
#endregion
# ============================================================================ #
