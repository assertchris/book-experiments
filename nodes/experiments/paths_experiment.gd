extends GameExperiment

func get_nearest_path(target : Vector2) -> ConnectedPath2D:
	var nearest : ConnectedPath2D
	var distance : float

	for node in get_children():
		if not node is ConnectedPath2D:
			continue

		var point = node.curve.get_closest_point(target)
		var point_distance = point.distance_to(target)

		if not distance or point_distance < distance:
			nearest = node
			distance = point_distance

	return nearest

func get_waypoints(start : ConnectedPath2D, end : ConnectedPath2D) -> Array:
	var sequences := []

	for connected in start.connected_paths.map(func(p): return start.get_node(p)):
		var pair = [
			start,
			connected,
		]

		if connected == end:
			return add_coordinates_to_waypoints(pair)

		sequences.push_back(pair)

	while sequences.size() > 0:
		var sequence = sequences.pop_front()

		var last = sequence[sequence.size() - 1]

		for connected in last.connected_paths.map(func(p): return last.get_node(p)):
			if sequence.has(connected):
				continue

			var appended = sequence + [connected]

			if connected == end:
				return add_coordinates_to_waypoints(appended)

			sequences.push_back(appended)

	return []

func add_coordinates_to_waypoints(route: Array) -> Array:
	var entries := {}

	for path in get_children().filter(func(node): return node is ConnectedPath2D):
		for connected in path.connected_paths.map(func(connected): return path.get_node(connected)):
			var nearest_path_point : Vector2
			var nearest_connected_point : Vector2
			var nearest_distance : float

			for path_point in path.curve.get_baked_points():
				for connected_point in connected.curve.get_baked_points():
					var distance = path_point.distance_to(connected_point)

					if not nearest_distance or distance < nearest_distance:
						nearest_path_point = path_point
						nearest_connected_point = connected_point
						nearest_distance = distance

			entries[str(path.get_instance_id()) + "-" + str(connected.get_instance_id())] = {
				"leave": nearest_path_point,
				"enter": nearest_connected_point,
			}

	var new_waypoints := []

	for i in route.size():
		var current = route[i]

		var waypoint = {
			"node": current,
		}

		if i > 0:
			var previous = route[i - 1]
			var key = str(previous.get_instance_id()) + "-" + str(current.get_instance_id())

			new_waypoints[i - 1].leave = entries[key].leave
			waypoint.enter = entries[key].enter

		new_waypoints.push_back(waypoint)

	return new_waypoints

@onready var _path_follow := %PathFollow2d as PathFollow2D

var nearest_path: ConnectedPath2D
var nearest_point: Vector2
var waypoints: Array
var speed := 200

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			nearest_path = get_nearest_path(get_local_mouse_position())
			nearest_point = get_nearest_point(nearest_path, get_local_mouse_position())
			waypoints = get_waypoints(_path_follow.get_parent(), nearest_path)

func get_nearest_point(nearest_path: ConnectedPath2D, target : Vector2) -> Vector2:
	return nearest_path.curve.get_closest_point(target)

func _process(delta: float) -> void:
	move_to_point(delta)

func move_to_point(delta : float) -> void:
	var current_path = _path_follow.get_parent()

	var target_i : int
	var current_i : int

	var points = current_path.curve.get_baked_points()
	var target : Vector2

	if waypoints.size() < 1 or current_path == waypoints.back().node:
		target = nearest_point
	else:
		target = waypoints.filter(func(w): return w.node == current_path).front().leave

	for i in range(points.size()):
		if points[i].distance_to(target) < 5:
			target_i = i

		if points[i].distance_to(_path_follow.position) < 5:
			current_i = i

	if abs(target_i - current_i) > 3:
		if target_i < current_i:
			_path_follow.progress -= delta * speed
		else:
			_path_follow.progress += delta * speed

	elif waypoints.size() > 0 and current_path != waypoints.back().node:
		for i in waypoints.size():
			if waypoints[i].node == current_path:
				var next_path = waypoints[i + 1].node

				current_path.remove_child(_path_follow)
				next_path.add_child(_path_follow)

				move_to_offset_position(waypoints[i + 1].enter)

func move_to_offset_position(target : Vector2) -> void:
	while target.distance_to(_path_follow.position) > 5:
		_path_follow.progress -= 1
