extends UI


@export var game_point_text: String
@onready var _score_label: Dictionary = {
    Global.SIDE_LEFT: $ScoreContainer/LeftScore,
    Global.SIDE_RIGHT: $ScoreContainer/RightScore,
}


# ============================================================================ #
#region Public methods
func update_score_labels(left_score: int, right_score: int, game_point_state) -> void:
    var left_score_label_text: String = "%s%d" %\
            [ game_point_text + " " if not game_point_state ^ 0b10 else "", left_score ]
    _score_label[Global.SIDE_LEFT].text = left_score_label_text
    var right_score_label_text: String = "%d%s" %\
            [ right_score, " " + game_point_text if not game_point_state ^ 0b01 else "" ]
    _score_label[Global.SIDE_RIGHT].text = right_score_label_text
#endregion
# ============================================================================ #
