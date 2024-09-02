class_name AStar2DVisualizer
extends Node2D


@export_group("Grid")
@export var tile_size: Vector2 = Vector2(16, 16)
@export_group("Appearance")
@export_range(0.1, 1.0, 0.1, "or_greater", "suffix:px") var point_radius: float = 6.0
@export var enabled_point_color: Color = Color("00ff0050")
@export var disabled_point_color: Color = Color("ff000040")
@export var path_point_color: Color = Color("ff00ffff")
@export var edge_color: Color = Color("0000ff30")
@export_range(0.1, 1.0, 0.1, "or_greater", "suffix:px") var edge_width: float = 2.0

var _map: AStar2D
var _paths_point_ids: Array[int]


# ============================================================================ #
#region Godot builtins
func _draw():
    if not _map: return
    for point_id in _map.get_point_ids():
        var point_position: Vector2 = _get_point_position(point_id)
        var point_color =\
                disabled_point_color if _map.is_point_disabled(point_id)\
                else path_point_color if point_id in _paths_point_ids\
                else enabled_point_color
        draw_circle(point_position, point_radius, point_color)

        for neighbor_point_id in _map.get_point_connections(point_id):
            var neighbor_position: Vector2 = _get_point_position(neighbor_point_id)
            if (
                    (abs(point_position.x - neighbor_position.x) == tile_size.x) != # XOR.
                    (abs(point_position.y - neighbor_position.y) == tile_size.y)
            ):
                draw_line(
                        point_position,
                        neighbor_position,
                        edge_color,
                        edge_width
                )
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func load_map(map: AStar2D) -> void:
    _map = map
    queue_redraw()


func add_id_path(id_path: Array[int]) -> void:
    _paths_point_ids.append_array(id_path)


func erase_id_path(id_path: Array[int]) -> void:
    for point_id in id_path:
        _paths_point_ids.erase(point_id)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _get_point_position(id) -> Vector2:
    return _map.get_point_position(id) * tile_size + tile_size / 2
#endregion
# ============================================================================ #
