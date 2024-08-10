class_name WorldGrid2D
extends Node
## 2D matrix of cells to represent game state/environment.
##
## Each cell can contain any type of data. Meant to be a flexible medium to be
## accessed and updated by children nodes/controller/logic.
## [br][br]
## For possible data types, see: [enum Variant.Type] and [member data_type].
## [br][br]
## [i]Note: The internal data structure is stored using row-major order, with
## 0-based indexing.[/i]


@export_group("Dimensions")
## Set this in the Inspector. Modifying this value during runtime has no effect.
## Use [method size] to safely access this value during runtime.
@export_range(1, 1, 1, "or_greater", "suffix:cells") var width: int = 1
## Set this in the Inspector. Modifying this value during runtime has no effect.
## Use [method size] to safely access this value during runtime.
@export_range(1, 1, 1, "or_greater", "suffix:cells") var height: int = 1

@export_group("Data")
## Set this in the Inspector. Modifying this value during runtime has no effect.
##
## Setting this as [constant TYPE_NIL] or [constant TYPE_MAX] would throw an
## Invalid Value error during runtime.
@export var data_type: Variant.Type = TYPE_NIL
## Set this in the Inspector. Modifying this value during runtime has no effect.
##
## Set this as any [b]native[/b] class name, for example [code]Node[/code]. If
## [member data_type] is not [const TYPE_OBJECT], must be an empty string.
@export var data_class: StringName = &""
## Set this in the Inspector. Modifying this value during runtime has no effect.
##
## Should be set if this matrix is meant to store instances of a custom class.
@export var class_script: Script = null

var _cells: Array
var _width: int
var _height: int
var _numel: int


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
    for i in _numel:
        _cells.append(_get_default_value(data_type))
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
func size(dim: int) -> int:
    match dim:
        Vector2i.AXIS_X:
            return _width
        Vector2i.AXIS_Y:
            return _height
        _:
            assert(false, "Invalid value: dim: %d" % dim)
            return -1


func numel() -> int:
    return _numel


func get_at(coords: Vector2i) -> Variant:
    return _cells[coords.x + _width * coords.y]


func set_at(coords: Vector2i, value: Variant) -> void:
    _cells[coords.x + _width * coords.y] = value
#endregion
# ============================================================================ #


# ============================================================================ #
#region Utils
func _get_default_value(type: Variant.Type) -> Variant:
    match type:
        TYPE_BOOL:
            return false
        TYPE_INT:
            return 0
        TYPE_FLOAT:
            return .0
        TYPE_STRING:
            return 0
        TYPE_VECTOR2:
            return Vector2()
        TYPE_VECTOR2I:
            return Vector2i()
        TYPE_RECT2:
            return Rect2()
        TYPE_RECT2I:
            return Rect2i()
        TYPE_VECTOR3:
            return Vector3()
        TYPE_VECTOR3I:
            return Vector3i()
        TYPE_TRANSFORM2D:
            return Transform2D()
        TYPE_VECTOR4:
            return Vector4()
        TYPE_VECTOR4I:
            return Vector4i()
        TYPE_PLANE:
            return Plane()
        TYPE_QUATERNION:
            return Quaternion()
        TYPE_AABB:
            return AABB()
        TYPE_BASIS:
            return Basis()
        TYPE_TRANSFORM3D:
            return Transform3D()
        TYPE_PROJECTION:
            return Projection()
        TYPE_COLOR:
            return Color()
        TYPE_STRING_NAME:
            return StringName()
        TYPE_NODE_PATH:
            return NodePath()
        TYPE_RID:
            return RID()
        TYPE_CALLABLE:
            return Callable()
        TYPE_SIGNAL:
            return Signal()
        TYPE_DICTIONARY:
            return Dictionary()
        TYPE_ARRAY:
            return Array()
        TYPE_PACKED_BYTE_ARRAY:
            return PackedByteArray()
        TYPE_PACKED_INT32_ARRAY:
            return PackedInt32Array()
        TYPE_PACKED_INT64_ARRAY:
            return PackedInt64Array()
        TYPE_PACKED_FLOAT32_ARRAY:
            return PackedFloat32Array()
        TYPE_PACKED_FLOAT64_ARRAY:
            return PackedFloat64Array()
        TYPE_PACKED_STRING_ARRAY:
            return PackedStringArray()
        TYPE_PACKED_VECTOR2_ARRAY:
            return PackedVector2Array()
        TYPE_PACKED_VECTOR3_ARRAY:
            return PackedVector3Array()
        TYPE_PACKED_COLOR_ARRAY:
            return PackedColorArray()
        TYPE_MAX:
            assert(false, "Invalid value: TYPE_MAX (%d) is not allowed" % TYPE_MAX)
            return null
        TYPE_NIL:
            assert(false, "Invalid value: TYPE_NIL (%d) is not allowed" % TYPE_NIL)
            return null
        _:
            return null
#endregion
# ============================================================================ #
