extends Control


# ============================================================================ #
#region Game loop
func _ready() -> void:
	$MainMenuContainer/QuitButton.connect("pressed", _on_main_menu_quit_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners
## Listens to MainMenuContainer/QuitButton.pressed()
func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()
#endregion
# ============================================================================ #
