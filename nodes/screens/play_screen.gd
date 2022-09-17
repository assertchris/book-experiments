extends GameScreen

@export var experiment_scene : PackedScene

@onready var _anchor := $Center/Anchor

func _ready() -> void:
	var experiment = experiment_scene.instantiate()
	_anchor.add_child(experiment)
