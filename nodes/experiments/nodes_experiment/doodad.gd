extends ColorRect

func _ready() -> void:
	var number = randf()

	if number > 0.9:
		color = Color.DARK_GREEN
	elif number > 0.7:
		color = Color.SADDLE_BROWN
	else:
		color = Color.TRANSPARENT
