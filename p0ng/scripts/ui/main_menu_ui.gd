extends Control


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
	$MainMenuContainer/StartButton.connect("pressed", _on_main_menu_start_button_pressed)
	$MainMenuContainer/QuitButton.connect("pressed", _on_main_menu_quit_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners
## Listens to MainMenuContainer/QuitButton.pressed()
func _on_main_menu_start_button_pressed() -> void:
	var tween = create_tween()


## Listens to MainMenuContainer/QuitButton.pressed()
func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()
#endregion
# ============================================================================ #
