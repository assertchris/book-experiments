extends GameExperiment

@export var layout_texture : Texture2D

enum types {
	none,
	tree,
	rock,
	player,
}

const type_colors := {
	types.tree: "65a30d",
	types.rock: "57534e",
	types.player: "ea580c",
}

func _ready() -> void:
	var layout = get_layout()
	var flipped_layout = flip_layout(layout, flip_axis.y)
	# ...do something with the layout

func get_layout() -> Array[Array]:
	var layout_image := layout_texture.get_image()
	var rows := []

	for y in layout_texture.get_height():
		var row := []

		for x in layout_texture.get_width():
			var type := types.none
			var color := layout_image.get_pixel(x, y).to_html(false)

			for t in types.values():
				if not type_colors.has(t):
					continue

				if color == type_colors[t]:
					type = t

			row.append(type)
		rows.append(row)

	return rows

enum flip_axis {
	none,
	x,
	y,
}

func flip_layout(layout: Array[Array], flip := flip_axis.none) -> Array[Array]:
	var new_rows := []

	for row in layout:
		var new_row := []

		for cell in row:
			if flip == flip_axis.x:
				new_row.push_front(cell)
			else:
				new_row.push_back(cell)

		if flip == flip_axis.y:
			new_rows.push_front(new_row)
		else:
			new_rows.push_back(new_row)

	return new_rows
