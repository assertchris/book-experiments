extends GameExperiment

@onready var _tile_map := $TileMap as TileMap

func _ready() -> void:
	_tile_map.clear()

#	var cells := [
#        [Vector2(0, -2), Vector2(19, 0)],
#        [Vector2(1, -2), Vector2(19, 0)],
#        [Vector2(2, -2), Vector2(20, 0)],
#        [Vector2(2, -1), Vector2(20, 1)],
#        [Vector2(2, 0), Vector2(20, 1)],
#    ]
#
#    for cell in cells:
#        _tile_map.set_cell(0, cell[0], 2, cell[1])

	var cells : Array[Vector2i] = [
		Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
	]

	_tile_map.set_cells_terrain_connect(0, cells, 0, 0, false)
