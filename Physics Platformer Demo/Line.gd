extends Node3D

# Variables
var character_node = null
var projectile_node = null

# References
@onready var line_mesh = $MeshInstance3D

func _process(delta):
	update_line()

func update_line():
	if is_instance_valid(character_node) and is_instance_valid(projectile_node):
		var start_pos = character_node.global_transform.origin
		var end_pos = projectile_node.global_transform.origin
		
		var line_direction = (end_pos - start_pos).normalized()
		var line_length = start_pos.distance_to(end_pos)
		
		line_mesh.look_at_from_position(start_pos, end_pos, Vector3.UP)
		line_mesh.mesh.height = line_length
		line_mesh.global_transform.origin = start_pos + line_direction * line_length / 2

func set_character_node(node):
	character_node = node

func set_projectile_node(node):
	projectile_node = node
