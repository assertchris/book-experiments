extends GameExperiment

@export var doodad_scene : PackedScene

@onready var _items := $Items

func _ready() -> void:
	for i in range(25):
		var doodad = doodad_scene.instantiate()
		_items.add_child(doodad)
