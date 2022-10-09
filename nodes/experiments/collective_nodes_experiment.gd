extends GameExperiment

var width := 1
var height := 1

func _ready() -> void:
	render()

func _on_width_option_button_item_selected(index: int) -> void:
	width = index + 1
	render()

func _on_height_option_button_item_selected(index: int) -> void:
	height = index + 1
	render()

@onready var _color_rect := $HBoxContainer/ColorRect as ColorRect

func render() -> void:
	for group in _color_rect.get_children():
		for child in (group as Node2D).get_children():
			(child as TileMap).visible = false

	var intended_name := str(width) + "x" + str(height)
	var intended_node := _color_rect.get_node(intended_name)
	var index = randi() % intended_node.get_child_count()

	(intended_node.get_child(index) as TileMap).visible = true
