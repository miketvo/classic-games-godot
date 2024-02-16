extends Control


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
	$MainMenuContainer/StartButton.connect("pressed", _on_main_menu_start_button_pressed)
	$MainMenuContainer/QuitButton.connect("pressed", _on_main_menu_quit_button_pressed)

	$StartMenuContainer/BackButton.connect("pressed", _on_start_menu_back_button_pressed)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_start_button_pressed() -> void:
	_slide_transition($MainMenuContainer, Vector2.LEFT, 0.5)
	_slide_transition($StartMenuContainer, Vector2.LEFT, 0.5)


## Listens to $MainMenuContainer/QuitButton.pressed()
func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()


## Listens to $StartMenuContainer/BackButton.pressed()
func _on_start_menu_back_button_pressed() -> void:
	_slide_transition($MainMenuContainer, Vector2.RIGHT, 0.5)
	_slide_transition($StartMenuContainer, Vector2.RIGHT, 0.5)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _slide_transition(
		ui_element: Control,
		direction_vector: Vector2,
		duration: float
) -> void:
	if direction_vector not in [ Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT ]:
		assert(false, "MainMenuUI._slide_transition() only accepts unit vector for `direction_vector`")

	var tween = create_tween()
	tween.tween_property(
			ui_element, "position",
			ui_element.position + direction_vector * (
					get_viewport_rect().size.x / 2 + \
					ui_element.size.x * ui_element.scale.x / 2
			),
			duration
	)
#endregion
# ============================================================================ #
