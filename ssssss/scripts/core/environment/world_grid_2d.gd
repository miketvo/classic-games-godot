class_name WorldGrid2D
extends RefCounted
## Specialized typed 2D matrix of cells to represent game state/environment.
##
## The cells can contain any type of data. Meant to be a flexible medium to be
## accessed and updated by children nodes/controller/logic.
## [br][br]
## For usage, see [method _init].
## [br][br]
## [b]Note:[/b] The internal cell data layout is in row-major order, with
## 0-based indexing.


## Determines whether the grid represents a wrap-around space, i.e. the opposite
## edges' cells are connected
## ([url=https://en.wikipedia.org/wiki/Clifford_torus]Euclidean 2-torus /
## Clifford torus[/url]). Affects distance calculation and pathfinding
## algorithms. Below is an example of such a space, where anything that moves
## off an edge or corner cell A, B, or C, "reappears" on the opposite A, B, or C
## cell with its orientation, velocity, angular speed, etc. preserved:
## [codeblock]
## C A A A A C
## B . . . . B
## B . . . . B
## B . . . . B
## C A A A A C
## [/codeblock]
var wraparound: bool

# Internal data structure representing the cell grid. Cells MUST be get or set
# using [method get_at] and [method set_at].
var _cells: Array
var _width: int   # The width of the grid. Read-only.
var _height: int  # The height of the grid. Read-only.


# ============================================================================ #
#region Godot builtins

## To use [b]WorldGrid2D[/b], you need to create a new instance of the class
## with the correct parameters for your use case:
## [codeblock]
## class_name GameWorld
## extends Node2D
##
## class Powerup:
##     ...
##
## func _ready():
##     var wall_grid = WorldGrid2D.new(Vector2i(6, 7), TYPE_INT, &"", null)
##     var maze_walls = [
##        1, 1, 1, 1, 1, 1, 1,
##        0, 0, 1, 0, 1, 0, 1,
##        1, 0, 0, 0, 0, 0, 0,
##        1, 0, 1, 0, 1, 1, 1,
##        1, 0, 1, 0, 0, 0, 1,
##        1, 1, 1, 1, 1, 1, 1,
##     ]
##     wall_grid.load_array(maze_walls)
##     print(wall_grid.l1_distance(Vector2i(0, 1), Vector2i(2, 2)))
##     var coin_grid = WorldGrid2D.new(Vector2i(6, 7), TYPE_OBJECT, &"Node2D", Coin
##     var powerup_grid = WorldGrid2D.new(Vector2i(6, 7), TYPE_OBJECT, &"RefCounted", Powerup)
##     ...
## [/codeblock]
## The available [i]optional[/i] constructor parameters are:[br]
##  - [param dimensions] is the width and height of the grid. Both the
##    [code]x[/code] (width) and [code]y[/code] (height) components must be
##    non-zero positive integers.[br]
##  - [param data_type] is the data type that the grid is assigned to store in
##    its cells, for example [const TYPE_INT]. [b]Note:[/b] Passing
##    [constant TYPE_NIL] or [constant TYPE_MAX] would throw an Invalid Value
##    error during runtime.[br]
##  - [param data_class] is the [b]native[/b] class name, for example
##    [class Node]. If type is not [const TYPE_OBJECT], must be an empty string.
##    [br]
##  - [param class_script] is the associated script with the [param data_class].
##    Must be a [class Script] instance or [code]null[/code] when
##    [param data_type] is [const TYPE_OBJECT], must be set along with
##    [param data_class], and must be [code]null[/code] otherwise. Should be set
##    if this grid is meant to store instances of a custom class.[br]
##  - [param base] is the base array to be loaded into the grid cells. Its
##    elements must be of matching type/class/script with [param data_type],
##    [param data_class], and [param class_script].[br]
##  - [param wraparound] - see [member wraparound].[br]
## For possible data types, see: [enum Variant.Type]. The default value for all
## cells in the grid is the default value for their type (i.e. empty cells). See
## [method get_cell_default] for all default values.
@warning_ignore("shadowed_variable")
func _init(
        dimensions: Vector2i = Vector2i.ONE,
        data_type: Variant.Type = TYPE_BOOL,
        data_class: StringName = &"",
        class_script: Script = null,
        base: Array[Variant] = [],
        wraparound: bool = false
) -> void:
    assert(
            data_type == TYPE_OBJECT or data_class == &"",
            "Invalid value: `data_class` must be an empty string when `data_type` is not TYPE_OBJECT"
    )
    assert(
            data_type == TYPE_OBJECT or not class_script,
            "Invalid value: `class_script` must be null when `data_type` is not TYPE_OBJECT"
    )
    assert(
            data_class != &"" or not class_script,
            "`class_script` can only be set together with `data_class`"
    )
    assert(
            dimensions.x > 0 and dimensions.y > 0,
            "Invalid WorldGrid2D dimensions: %d by %d cells" \
            % [dimensions.x, dimensions.y]
    )

    self.wraparound = wraparound
    _width = dimensions.x
    _height = dimensions.y
    _cells = Array([], data_type, data_class, class_script)
    if base.is_empty():
        _cells.resize(_width * _height)
        _cells.fill(get_cell_default(data_type))
    else:
        load_array(base)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Populate/overwrite all cells in the grid with values from an array. The input
## parameter [param from] must be non-empty, and have the correct
## [method Array.size] matching the dimensions of the grid. Its elements also
## need to be of the correct type/class/script.
func load_array(from: Array[Variant]) -> void:
    assert(not from.is_empty(), "Cannot populate grid using empty array")
    assert(
            _width * _height == from.size(),
            "Dimensions mismatch: %d-element array does not match %d by %d grid" \
            % [from.size(), _width, _height]
    )
    for element: Variant in from:  # Exhaustive type checking.
        assert(
                _cells.get_typed_builtin() == typeof(element),
                "Array element type mismatch with grid: element type does not match %s" \
                % type_string(_cells.get_typed_builtin())
        )
        if (
                _cells.get_typed_builtin() == TYPE_OBJECT and
                _cells.get_typed_class_name() != &""
        ):
            assert(
                    element.is_class(_cells.get_typed_class_name()),
                    "Array element class mismatch with grid: element does not inherit from %s" \
                    % _cells.get_typed_class_name()
            )
            if _cells.get_typed_script():
                assert(
                        (
                                element.get_script() and
                                element.get_script() == _cells.get_typed_script()
                        ),
                        "Array element typed script mismatch with grid"
                )

    _cells = from.duplicate()  # Import data.


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
            assert(false, "Invalid value: `axis` = %d" % axis)
            return -1


## Returns the total number of cells in the grid.
func numel() -> int:
    return _cells.size()


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
    assert(0 <= coords.x and coords.x < _width, "`coord.x` = %d out of bounds" % coords.x)
    assert(0 <= coords.y and coords.y < _height, "`coord.y` = %d out of bounds" % coords.y)
    return _cells[coords.x + _width * coords.y]


## Set the cell value at [param coords].
func set_at(coords: Vector2i, value: Variant) -> void:
    assert(0 <= coords.x and coords.x < _width, "`coord.x` = %d out of bounds" % coords.x)
    assert(0 <= coords.y and coords.y < _height, "`coord.y` = %d out of bounds" % coords.y)
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
                    (where.end.x <= _width and where.end.y <= _height)
            ),
            "`where` = (%d, %d, %d, %d) out of bounds" % [
                where.position.x, where.position.y,
                where.end.x, where.end.y
            ]
    )

    var find_range: Rect2i = where
    if not find_range.has_area():
        find_range = Rect2i(Vector2i(0, 0), Vector2i(_width, _height))

    for i in range(numel()):
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
    for i in range(numel()):
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
    assert(0 <= c1.x and c1.x < _width, "`c1.x` = %d out of bounds" % c1.x)
    assert(0 <= c1.y and c1.y < _height, "`c1.y` = %d out of bounds" % c1.y)
    assert(0 <= c2.x and c2.x < _width, "`c2.x` = %d out of bounds" % c2.x)
    assert(0 <= c2.y and c2.y < _height, "`c2.y` = %d out of bounds" % c2.y)

    var dx: int = abs(c1.x - c2.x)
    if wraparound and dx > .5 * _width:
        dx = _width - dx

    var dy: int = abs(c1.y - c2.y)
    if wraparound and dy > .5 * _height:
        dy = _height - dy

    return dx + dy


## Returns the Euclidean (L2 Norm) distance between two cell coordinates.
func l2_distance(c1: Vector2i, c2: Vector2i) -> float:
    assert(0 <= c1.x and c1.x < _width, "`c1.x` = %d out of bounds" % c1.x)
    assert(0 <= c1.y and c1.y < _height, "`c1.y` = %d out of bounds" % c1.y)
    assert(0 <= c2.x and c2.x < _width, "`c2.x` = %d out of bounds" % c2.x)
    assert(0 <= c2.y and c2.y < _height, "`c2.y` = %d out of bounds" % c2.y)

    if wraparound:
        return sqrt(l2_distance_squared(c1, c2))
    else:
        return Vector2(c1).distance_to(Vector2(c2))


## Returns the squared Euclidean (L2 Norm) distance between two cell
## coordinates.
## [br][br]
## This method runs faster than [method l2_distance], so prefer it if you need
## to compare vectors or need the squared distance for some formula.
func l2_distance_squared(c1: Vector2i, c2: Vector2i) -> float:
    assert(0 <= c1.x and c1.x < _width, "`c1.x` = %d out of bounds" % c1.x)
    assert(0 <= c1.y and c1.y < _height, "`c1.y` = %d out of bounds" % c1.y)
    assert(0 <= c2.x and c2.x < _width, "`c2.x` = %d out of bounds" % c2.x)
    assert(0 <= c2.y and c2.y < _height, "`c2.y` = %d out of bounds" % c2.y)

    if wraparound:
        var dx: float = abs(c1.x - c2.x)
        if dx > .5 * _width:
            dx = _width - dx

        var dy: float = abs(c1.y - c2.y)
        if dy > .5 * _height:
            dy = _height - dy

        return dx * dx + dy * dy
    else:
        return Vector2(c1).distance_squared_to(Vector2(c2))


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
