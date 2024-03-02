extends UI


var input_disabled: bool

@onready var _main_menu: Container = $MainMenuContainer
@onready var _start_menu: Container = $StartMenuContainer


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    input_disabled = false
    %StartButton.grab_focus()
    %StartButton.connect("pressed", _on_main_menu_start_button_pressed)
    %QuitButton.connect("pressed", _on_main_menu_quit_button_pressed)
    %OnePlayerButton.connect("pressed", _on_start_menu_one_player_button_pressed)
    %TwoPlayersButton.connect("pressed", _on_start_menu_two_players_button_pressed)
    _start_menu.get_node("BackButton").connect("pressed", _on_start_menu_back_button_pressed)


func _input(_event: InputEvent) -> void:
    if input_disabled:
        # Stops event propagation to child nodes, effectively disabling inputs
        accept_event()
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

#region Listens to _main_menu.get_node("*")*.
func _on_main_menu_start_button_pressed() -> void:
    input_disabled = true
    _start_menu.get_node("OnePlayerButton").grab_focus()
    tween_transition_slide_container(_main_menu, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container(_start_menu, Vector2.LEFT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)


func _on_main_menu_quit_button_pressed() -> void:
    get_tree().quit()
#endregion


#region Listens to _start_menu.get_node("*").
func _on_start_menu_one_player_button_pressed() -> void:
    button_pressed.emit("start_one_player")


func _on_start_menu_two_players_button_pressed() -> void:
    button_pressed.emit("start_two_players")


func _on_start_menu_back_button_pressed() -> void:
    input_disabled = true
    _main_menu.get_node("StartButton").grab_focus()
    tween_transition_slide_container(_start_menu, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
    tween_transition_slide_container(_main_menu, Vector2.RIGHT, UI_TRANSITION_DURATION)\
            .connect("finished", _on_tween_transition_finshed)
#endregion


# Listens to tween transition Tween.finished() to re-enable input.
func _on_tween_transition_finshed() -> void:
    input_disabled = false

#endregion
# ============================================================================ #
