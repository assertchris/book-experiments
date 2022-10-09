extends GameExperiment

@onready var _player := $Sprite2d as Sprite2D
@onready var _agent := $Sprite2d/NavigationAgent2d as NavigationAgent2D
@onready var _destination := $Marker2d as Marker2D

@onready var _region := $NavigationRegion2d as NavigationRegion2D

func cut_out_areas() -> void:
	var nodes := get_tree().get_nodes_in_group("non_navigable_entity")
	var groups := {}

	for node in nodes:
		var result := find_intersections(node, nodes, groups)
		nodes = result.nodes
		groups = result.groups

	for key in groups.keys():
		for node in groups[key]:
			var result := find_intersections(node, nodes, groups, key)
			nodes = result.nodes
			groups = result.groups

	for key in groups.keys():
		var outlines := []

		for node in groups[key]:
			outlines.append(get_outline(node))

		var combined = outlines[0]

		for outline in outlines.slice(1):
			combined = Geometry2D.merge_polygons(combined, outline)[0]

		_region.navpoly.add_outline(combined)
		_region.navpoly.make_polygons_from_outlines()

	for node in nodes:
		_region.navpoly.add_outline(get_outline(node))
		_region.navpoly.make_polygons_from_outlines()

func _ready() -> void:
	cut_out_areas()

	_agent.velocity_computed.connect(
		func(velocity: Vector2) -> void:
			_player.global_position += velocity
	)

	_agent.set_target_location(_player.global_position)

	await get_tree().create_timer(1.0).timeout

	_agent.set_target_location(_destination.global_position)

func _physics_process(delta: float) -> void:
	var next_location := _agent.get_next_location()
	var next_velocity := next_location - _player.global_position
	_agent.set_velocity(next_velocity)

var auto_number = 0

func find_intersections(node, nodes, groups, group_id = null) -> Dictionary:
	var node_collider := node.get_node("CollisionPolygon2d") as CollisionPolygon2D
	var node_polygon := node_collider.get_polygon()

	for other_node in nodes:
		if other_node == node:
			continue

		var other_node_collider := other_node.get_node("CollisionPolygon2d") as CollisionPolygon2D
		var other_node_polygon := other_node_collider.get_polygon()

		var result := Geometry2D.intersect_polygons(node_polygon * node.transform, other_node_polygon * other_node.transform)

		if result.size() > 0:
			if group_id == null:
				group_id = auto_number
				groups[group_id] = []
				groups[group_id].append(node)
				nodes.erase(node)
				auto_number += 1

			groups[group_id].append(other_node)
			nodes.erase(other_node)

	return {
		"nodes": nodes,
		"groups": groups,
	}

func get_outline(node) -> PackedVector2Array:
	var node_outline := PackedVector2Array()

	var node_collider := node.get_node("CollisionPolygon2d") as CollisionPolygon2D
	var node_polygon := node_collider.get_polygon()

	for vertex in node_polygon:
		node_outline.append(node.transform * vertex)

	return node_outline
