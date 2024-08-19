extends Node2D


var _source_ids: Dictionary


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
    var children: Array[Node] = get_children()
    for child in children:
        assert(child is TileMapLayer, "TileMap must contain only TileMapLayers")

        var layer: TileMapLayer = child
        var layer_sources: Dictionary
        for source_index in range(layer.tile_set.get_source_count()):
            var source_id: int = layer.tile_set.get_source_id(source_index)
            var source_name: String = layer.tile_set.get_source(source_id).resource_name
            layer_sources[source_name] = source_id
        _source_ids[layer.name] = layer_sources

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [TileSetSource] ID of the [TileSet]s used in [param layer] given
## the [param source_name].
func get_source_id(layer: String, source_name: String) -> int:
    return _source_ids[layer][source_name]

#endregion
# ============================================================================ #
