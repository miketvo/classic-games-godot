class_name WorldGrid2D
extends Node
## 2D matrix of cells to represent game state/environment.
##
## Each cell can contain any type of data. Meant to be a flexible medium to be
## accessed and updated by children nodes/controller/logic.
## [br][br]
## For possible data types, see: [enum Variant.Type] and [member data_type]. The
## default value for all cells in the grid is the default value for their type
## (i.e. empty cells). See [method get_cell_default] for all default values.
## [br][br]
## [b]Note:[\b] The internal data structure is stored using row-major order, with
## 0-based indexing.


@export_group("Dimensions")
## Set this in the [url=https://docs.godotengine.org/en/stable/tutorials/editor/inspector_dock.html]Inspector[/url].
## Modifying this value during runtime has no effect. Use [method size] to
## safely access this value during runtime.
@export_range(1, 1, 1, "or_greater", "suffix:cells") var width: int = 1
## Set this in the [url=https://docs.godotengine.org/en/stable/tutorials/editor/inspector_dock.html]Inspector[/url].
## Modifying this value during runtime has no effect. Use [method size] to
## safely access this value during runtime.
@export_range(1, 1, 1, "or_greater", "suffix:cells") var height: int = 1
## Determines whether the grid represents a wrap-around space, i.e. the opposite
## edges' cells are connected
## ([url=https://en.wikipedia.org/wiki/Clifford_torus]Euclidean 2-torus / Clifford torus[/url]).
## Affects distance calculation and pathfinding algorithms.
## [br][br]
## Below is an example of such a space, where anything that moves off an edge or
## corner cell A, B, or C, "reappears" on the opposite A, B, or C cell with its
## orientation, velocity, angular speed, etc. preserved:
## [codeblock]
## C A A A A C
## B . . . . B
## B . . . . B
## B . . . . B
## C A A A A C
## [/codeblock]
## Set this in the [url=https://docs.godotengine.org/en/stable/tutorials/editor/inspector_dock.html]Inspector[/url].
## Modifying this value during runtime has no effect. Use [method is_wraparound]
## to safely access this value during runtime.
@export var wraparound: bool = false

@export_group("Data")
## Set this in the [url=https://docs.godotengine.org/en/stable/tutorials/editor/inspector_dock.html]Inspector[/url].
## Modifying this value during runtime has no effect.
## [br][br]
## Setting this as [constant TYPE_NIL] or [constant TYPE_MAX] would throw an
## Invalid Value error during runtime.
@export var data_type: Variant.Type = TYPE_NIL
## Set this in the [url=https://docs.godotengine.org/en/stable/tutorials/editor/inspector_dock.html]Inspector[/url].
## Modifying this value during runtime has no effect.
## [br][br]
## Set this as any [b]native[/b] class name, for example [code]Node[/code]. If
## [member data_type] is not [const TYPE_OBJECT], must be an empty string.
@export var data_class: StringName = &""
## Set this in the [url=https://docs.godotengine.org/en/stable/tutorials/editor/inspector_dock.html]Inspector[/url].
## Modifying this value during runtime has no effect.
## [br][br]
## Should be set if this grid is meant to store instances of a custom class.
@export var class_script: Script = null

# WARN: DO NOT modify these private variables with the Inspector in debugging
# runs. The grid behavior when doing so is UNDEFINED, and may crash the game.
var _cells: Array      # Internal data structure. Cells MUST be get or set using [method get_at] and [method set_at].
var _width: int        # The width of the grid. Read-only.
var _height: int       # The height of the grid. Read-only.
var _numel: int        # Total number of cell in the grid. Read-only.
var _wraparound: bool  # See [member wraparound].


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    assert(
            not (data_type != TYPE_OBJECT and data_class != &""),
            "Invalid value: data_class must be an empty string when " + \
            "data_type is not TYPE_OBJECT (%d)" \
            % TYPE_OBJECT
    )

    _width = width
    _height = height
    _numel = _width * _height
    _cells = Array([], data_type, data_class, class_script)
    _cells.resize(_numel)
    _cells.fill(get_cell_default(data_type))
    _wraparound = wraparound
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the size of the specified [param axis].
## [codeblock]
## size(Vector2i.AXIS_X)  # returns the width of the grid.
## size(Vector2i.AXIS_Y)  # returns the height of the grid.
## [/codeblock]
func size(axis: int) -> int:
    match axis:
        Vector2i.AXIS_X:
            return _width
        Vector2i.AXIS_Y:
            return _height
        _:
            assert(false, "Invalid value: axis: %d" % axis)
            return -1


## Returns the total number of cells in the grid.
func numel() -> int:
    return _numel


## Returns [code]true[/code] if the grid contains the given [param value].
func has(value: Variant) -> bool:
    return _cells.has(value)


## Returns the minimum value contained in the grid if the grid is of comparable
## data types. If the cells can't be compared, [code]null[/code] is returned.
## [br][br]
## See also [method max] for an example of using a custom comparator.
func min() -> Variant:
    return _cells.min()


## Returns the maximum value contained in the grid if the grid is of comparable
## data types. If the cells can't be compared, [code]null[/code] is returned.
## [br][br]
## To find the maximum value using a custom comparator, use [method redyce]. In
## this example every cell is checked and the first maximum value is returned:
## [codeblock]
## func _ready():
##     var grid = $WorldGrid2D  # Contains cells of Vector2 type.
##     # In this example we compare the lengths.
##     print(grid.reduce(func(max, val): return val if is_length_greater(val, max) else max))
##
## func is_length_greater(a: Vector2, b: Vector2):
##     return a.length() > b.length()
## [/codeblock]
func max() -> Variant:
    return _cells.max()


## Returns the cell value at [param coords].
func get_at(coords: Vector2i) -> Variant:
    assert(0 >= coords.x and coords.x < _width, "coord.x (%d) out of bounds" % coords.x)
    assert(0 >= coords.y and coords.y < _height, "coord.y (%d) out of bounds" % coords.y)
    return _cells[coords.x + _width * coords.y]


## Set the cell value at [param coords].
func set_at(coords: Vector2i, value: Variant) -> void:
    assert(0 >= coords.x and coords.x < _width, "coord.x (%d) out of bounds" % coords.x)
    assert(0 >= coords.y and coords.y < _height, "coord.y (%d) out of bounds" % coords.y)
    _cells[coords.x + _width * coords.y] = value


## Searches the grid for the first cell (top-leftmost in row-major order)
## containing the value [param what] and returns its coordinates or
## [code](-1, -1)[/code] if not not found.
## [br][br]
## Optionally, the [class Rect2i] search range [param where] can be passed. By
## convention, coordinates on the right and bottom edges of this range are
## [b]not[/b] included. [b]Note:[/b] Regardless of [member wraparound],
## [param where] does not accept [class Rect2i] with negative
## [member Rect2i.size]. Use [method Rect2i.abs] first to get a valid rectangle.
## It also does not accept any rectangle with [param Rect2i.end] outside of the
## grid width and height range.
func find(what: Variant, where: Rect2i = Rect2i()) -> Vector2i:
    assert(
            (
                    (where.position.x >= 0 and where.position.y > 0) and
                    (where.end.x <= width and where.end.y <= height)
            ),
            "where rectangle (%d, %d, %d, %d) out of bounds" % [
                where.position.x, where.position.y,
                where.end.x, where.end.y
            ]
    )

    var find_range: Rect2i = where
    if not find_range.has_area():
        find_range = Rect2i(Vector2i(0, 0), Vector2i(_width, _height))

    for i in range(_numel):
        @warning_ignore("integer_division")
        var y: int = i / _width
        var x: int = i % _width
        var current_coords = Vector2i(x, y)
        if find_range.has_point(current_coords) and what == get_at(current_coords):
            return current_coords
    return Vector2i(-1, -1)


## Calls the provided [class Callable] [param method] on each cell of the grid
## and returns [code]true[/code] if [param method] returns [code][/code] true
## for [i]all[/i] cells in the grid.
## [br][br]
## The [class Callable] [param method] should take one [class Variant]
## parameter (the value of the current cell) and return a boolean value.
## [br][br]
## [b]Note:[/b] For an empty grid, this method always returns [code]true[/code].
## [br][br]
## See also [method any], [method filter], [method map], and [method reduce].
## [b]Note:[/b] This method will return as early as possible to improve
## performance (especially with large grid).
func all(method: Callable) -> bool:
    return _cells.all(method)


## Calls the provided [class Callable] [param method] on each cell of the grid
## and returns [code]true[/code] if [param method] returns [code][/code] true
## for [i]one or more[/i] cells in the grid.
## [br][br]
## The [class Callable] [param method] should take one [class Variant]
## parameter (the value of the current cell) and return a boolean value.
## [br][br]
## [b]Note:[/b] For an empty grid, this method always returns
## [code]false[/code].
## [br][br]
## See also [method all], [method filter], [method map], and [method reduce].
## [b]Note:[/b] This method will return as early as possible to improve
## performance (especially with large grid).
func any(method: Callable) -> bool:
    return _cells.any(method)


## Calls the provided [class Callable] [param method] for each cell of the grid
## and accumulates the result in [param accum].
## [br][br]
## The [class Callable] [param method] should take two arguments: the current
## value of [param accum] and the current cell value. If [param accum] is
## [code]null[/code] (default value), the iteration will start from cell (0, 1),
## with cell (0, 0) used as the intial value of [param accum].
## [br][br]
## See also [method map], [method filter], [method any], and [method all].
func reduce(method: Callable, accum: Variant = null) -> Variant:
    return _cells.reduce(method, accum)


## Calls the provided [class Callable] [param method] for each cell of the grid
## and modify those cells in-place with values returned by the [param method].
## [br][br]
## The [class Callable] [param method] should take one [class Variant]
## parameter (the current cell value) and return any [class Variant].
## [br][br]
## See also [method filter], [method reduce], [method any], and [method all].
## [b]Note:[/b] The effect of this method is irreversible. Duplicate the
## [WorldGrid2D] programatically with [method Node.duplicate] to preserve the
## original grid.
func map(method: Callable) -> void:
    _cells = _cells.map(method)


## Calls the provided [class Callable] [param method] on each cell of the grid
## and returns a new array containing the [class Vector2i] coordinates of the
## cells for which the [param method] returned [code]true[/code].
## [br][br]
## The [class Callable] [param method] should take one [class Variant]
## parameter (the current cell value) and return a boolean value.
## [br][br]
## See also [method any], [method all], [method map], and [method reduce].
func filter(method: Callable) -> Array[Vector2i]:
    var filtered_coords: Array[Vector2i] = []
    for i in range(_numel):
        @warning_ignore("integer_division")
        var y: int = i / _width
        var x: int = i % _width
        if method.call(get_at(Vector2i(x, y))):
            filtered_coords.append(Vector2i(x, y))
    return filtered_coords


## Fill the grid (in-place) with [param value].
func fill(value: Variant) -> void:
    _cells.fill(value)


## Reset (in-place) all cells in the grid with the default value for its type.
## See [method get_cell_default] for all default values.
func reset() -> void:
    _cells.fill(get_cell_default(_cells.get_typed_builtin()))


## Reset (in-place) the cell at [param coords] with the default value for its
## type. See [method get_cell_default] for all default values.
func reset_at(coords: Vector2i) -> void:
    set_at(coords, get_cell_default(_cells.get_typed_builtin()))


## Returns [code]true[/code] if the grid only contains empty cells (cells that
## contains the default value for its type). See [method get_cell_default] for
## all default values.
func is_clear() -> bool:
    return all(func(cell): return cell == get_cell_default(_cells.get_typed_builtin()))


## Returns the Manhattan/Taxicab (L1 Norm) distance between two cell
## coordinates.
func l1_distance(c1: Vector2i, c2: Vector2i) -> int:
    assert(0 >= c1.x and c1.x < _width, "c1.x (%d) out of bounds" % c1.x)
    assert(0 >= c1.y and c1.y < _height, "c1.y (%d) out of bounds" % c1.y)
    assert(0 >= c2.x and c2.x < _width, "c2.x (%d) out of bounds" % c2.x)
    assert(0 >= c2.y and c2.y < _height, "c2.y (%d) out of bounds" % c2.y)

    var dx: int = abs(c1.x - c2.x)
    if is_wraparound() and dx > .5 * _width:
        dx = _width - dx

    var dy: int = abs(c1.y - c2.y)
    if is_wraparound() and dy > .5 * _height:
        dy = _height - dy

    return dx + dy


## Returns the traverse distance (L1 Norm) between two cell coordinates, taking
## into account non-traversable cells (i.e. obstacles).
## [br][br]
## Set the traversible cell values with [param traversible]. Defaults to empty
## cells (cells that contains the default value for its type).
## [br][br]
## Returns -1 when either [param c1] or [param c2] is a non-traversible cell, or
## if there is no possible path between the two cells.
## [br][br]
## Use [method l1_distance] instead when all cells in the grid should be
## traversable.
## @experimental
func t_distance(
        c1: Vector2i, c2: Vector2i,
        traversible: Array[Variant] = [get_cell_default(_cells.get_typed_builtin())]
) -> int:
    assert(0 >= c1.x and c1.x < _width, "c1.x (%d) out of bounds" % c1.x)
    assert(0 >= c1.y and c1.y < _height, "c1.y (%d) out of bounds" % c1.y)
    assert(0 >= c2.x and c2.x < _width, "c2.x (%d) out of bounds" % c2.x)
    assert(0 >= c2.y and c2.y < _height, "c2.y (%d) out of bounds" % c2.y)

    var traverse_map: Array[bool] = []
    traverse_map.resize(_numel)
    traverse_map.fill(false)
    for i in range(_numel):
        traverse_map[i] = not (get_at(Vector2i(0, 0)) in traversible)

    if is_wraparound():
        assert(false, "Not implemented")  # TODO: Implement this.
        return 0
    else:
        assert(false, "Not implemented")  # TODO: Implement this.
        return 0


## Returns the Euclidean (L2 Norm) distance between two cell coordinates.
func l2_distance(c1: Vector2i, c2: Vector2i) -> float:
    assert(0 >= c1.x and c1.x < _width, "c1.x (%d) out of bounds" % c1.x)
    assert(0 >= c1.y and c1.y < _height, "c1.y (%d) out of bounds" % c1.y)
    assert(0 >= c2.x and c2.x < _width, "c2.x (%d) out of bounds" % c2.x)
    assert(0 >= c2.y and c2.y < _height, "c2.y (%d) out of bounds" % c2.y)

    if is_wraparound():
        return sqrt(l2_distance_squared(c1, c2))
    else:
        return Vector2(c1).distance_to(Vector2(c2))


## Returns the squared Euclidean (L2 Norm) distance between two cell
## coordinates.
## [br][br]
## This method runs faster than [method l2_distance], so prefer it if you need
## to compare vectors or need the squared distance for some formula.
func l2_distance_squared(c1: Vector2i, c2: Vector2i) -> float:
    assert(0 >= c1.x and c1.x < _width, "c1.x (%d) out of bounds" % c1.x)
    assert(0 >= c1.y and c1.y < _height, "c1.y (%d) out of bounds" % c1.y)
    assert(0 >= c2.x and c2.x < _width, "c2.x (%d) out of bounds" % c2.x)
    assert(0 >= c2.y and c2.y < _height, "c2.y (%d) out of bounds" % c2.y)

    if is_wraparound():
        var dx: float = abs(c1.x - c2.x)
        if dx > .5 * _width:
            dx = _width - dx

        var dy: float = abs(c1.y - c2.y)
        if dy > .5 * _height:
            dy = _height - dy

        return dx * dx + dy * dy
    else:
        return Vector2(c1).distance_squared_to(Vector2(c2))


## Returns [code]true[/code] if the grid represents an Euclidean 2-torus. See
## [member wraparound].
func is_wraparound() -> bool:
    return _wraparound


## Returns the default cell value for the corresponding [param type].
## [b]Note:[/b] [const TYPE_NIL] and [const TYPE_MAX] are not allowed.
## [br][br]
## Available defaults:
## [codeblock]
## var defaults: Dictionary = {
##     TYPE_BOOL: false,
##     TYPE_INT: 0,
##     TYPE_FLOAT: .0,
##     TYPE_STRING: String(),
##     TYPE_VECTOR2: Vector2(),
##     TYPE_VECTOR2I: Vector2i(),
##     TYPE_RECT2: Rect2(),
##     TYPE_RECT2I: Rect2i(),
##     TYPE_VECTOR3: Vector3(),
##     TYPE_VECTOR3I: Vector3i(),
##     TYPE_TRANSFORM2D: Transform2D(),
##     TYPE_VECTOR4: Vector4(),
##     TYPE_VECTOR4I: Vector4i(),
##     TYPE_PLANE: Plane(),
##     TYPE_QUATERNION: Quaternion(),
##     TYPE_AABB: AABB(),
##     TYPE_BASIS: Basis(),
##     TYPE_TRANSFORM3D: Transform3D(),
##     TYPE_PROJECTION: Projection(),
##     TYPE_COLOR: Color(),
##     TYPE_STRING_NAME: StringName(),
##     TYPE_NODE_PATH: NodePath(),
##     TYPE_RID: RID(),
##     TYPE_CALLABLE: Callable(),
##     TYPE_SIGNAL: Signal(),
##     TYPE_DICTIONARY: Dictionary(),
##     TYPE_ARRAY: Array(),
##     TYPE_PACKED_BYTE_ARRAY: PackedByteArray(),
##     TYPE_PACKED_INT32_ARRAY: PackedInt32Array(),
##     TYPE_PACKED_INT64_ARRAY: PackedInt64Array(),
##     TYPE_PACKED_FLOAT32_ARRAY: PackedFloat32Array(),
##     TYPE_PACKED_FLOAT64_ARRAY: PackedFloat64Array(),
##     TYPE_PACKED_STRING_ARRAY: PackedStringArray(),
##     TYPE_PACKED_VECTOR2_ARRAY: PackedVector2Array(),
##     TYPE_PACKED_VECTOR3_ARRAY: PackedVector3Array(),
##     TYPE_PACKED_COLOR_ARRAY: PackedColorArray(),
## }
## [/codeblock]
func get_cell_default(type: Variant.Type) -> Variant:
    var defaults: Dictionary = {
        TYPE_BOOL: false,
        TYPE_INT: 0,
        TYPE_FLOAT: .0,
        TYPE_STRING: String(),
        TYPE_VECTOR2: Vector2(),
        TYPE_VECTOR2I: Vector2i(),
        TYPE_RECT2: Rect2(),
        TYPE_RECT2I: Rect2i(),
        TYPE_VECTOR3: Vector3(),
        TYPE_VECTOR3I: Vector3i(),
        TYPE_TRANSFORM2D: Transform2D(),
        TYPE_VECTOR4: Vector4(),
        TYPE_VECTOR4I: Vector4i(),
        TYPE_PLANE: Plane(),
        TYPE_QUATERNION: Quaternion(),
        TYPE_AABB: AABB(),
        TYPE_BASIS: Basis(),
        TYPE_TRANSFORM3D: Transform3D(),
        TYPE_PROJECTION: Projection(),
        TYPE_COLOR: Color(),
        TYPE_STRING_NAME: StringName(),
        TYPE_NODE_PATH: NodePath(),
        TYPE_RID: RID(),
        TYPE_CALLABLE: Callable(),
        TYPE_SIGNAL: Signal(),
        TYPE_DICTIONARY: Dictionary(),
        TYPE_ARRAY: Array(),
        TYPE_PACKED_BYTE_ARRAY: PackedByteArray(),
        TYPE_PACKED_INT32_ARRAY: PackedInt32Array(),
        TYPE_PACKED_INT64_ARRAY: PackedInt64Array(),
        TYPE_PACKED_FLOAT32_ARRAY: PackedFloat32Array(),
        TYPE_PACKED_FLOAT64_ARRAY: PackedFloat64Array(),
        TYPE_PACKED_STRING_ARRAY: PackedStringArray(),
        TYPE_PACKED_VECTOR2_ARRAY: PackedVector2Array(),
        TYPE_PACKED_VECTOR3_ARRAY: PackedVector3Array(),
        TYPE_PACKED_COLOR_ARRAY: PackedColorArray(),
    }

    if type in defaults.keys():
        return defaults[type]
    elif type == TYPE_MAX:
        assert(false, "Invalid value: TYPE_MAX (%d) is not allowed" % TYPE_MAX)
    elif type == TYPE_NIL:
        assert(false, "Invalid value: TYPE_NIL (%d) is not allowed" % TYPE_NIL)
    return null

#endregion
# ============================================================================ #
