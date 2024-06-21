extends CharacterBody3D

var speed = 450
var gravHook = 100
const MOVE_SPEED = 7
const JUMP_FORCE = 8.5
const GRAVITY = 20
const MAX_FALL_SPEED = 30
const DASH_FORCE = 20
const DASH_DURATION = 0.2
const GRAPPLE_SPEED = 20
const SWING_RADIUS = 5.0
const SWING_SPEED = 2.0

var y_velo = 0
var facing_right = true
var is_jumping = false
var is_dashing = false
var dash_timer = 0
var dash_direction = Vector3.ZERO
var custom_velocity = Vector3()
var hook_pos = Vector3()
var hooked = false
var grapple_direction = Vector3()
var grapple_timer = 0
var grapple_duration = 1.0
var swing_angle = 0.0

var line_mesh: ImmediateMesh
var line_material: StandardMaterial3D

var projectile_speed = 20.0
var latch_point = null
var rope_length = 10.0
var swing_force = 10.0
var gravity_force = 9.8
var projectile = null

var projectile_path = []
var projectile_hit = false

@onready var grapple_hook = $GrappleHook

func _ready():
	# Create the line mesh and material
	line_mesh = ImmediateMesh.new()
	line_material = StandardMaterial3D.new()
	line_material.vertex_color_use_as_albedo = true
	
	# Add the line mesh to the scene
	var line_mesh_instance = MeshInstance3D.new()
	line_mesh_instance.mesh = line_mesh
	line_mesh_instance.material_override = line_material
	add_child(line_mesh_instance)

func gravity():
	custom_velocity.y += gravHook
	custom_velocity.x += gravHook

func _process(delta):
	if hooked:
		# Clear the line mesh
		line_mesh.clear_surfaces()
		
		# Begin drawing the line
		line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		
		# Add the start and end points of the line
		var start_pos = global_transform.origin
		var end_pos = hook_pos
		line_mesh.surface_add_vertex(start_pos)
		line_mesh.surface_add_vertex(end_pos)
		
		# Set the line color
		line_mesh.surface_set_color(Color.BLACK)
		line_mesh.surface_set_color(Color.BLACK)
		
		# End drawing the line
		line_mesh.surface_end()
	else:
		# Clear the line mesh when not hooked
		line_mesh.clear_surfaces()
	
	# Draw projectile path
	if projectile_path.size() > 1:
		line_mesh.clear_surfaces()
		line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for i in range(projectile_path.size() - 1):
			line_mesh.surface_add_vertex(projectile_path[i])
			line_mesh.surface_add_vertex(projectile_path[i + 1])
			line_mesh.surface_set_color(Color.RED)
			line_mesh.surface_set_color(Color.RED)
		line_mesh.surface_end()

func _physics_process(delta):
	gravity()
	
	if is_inside_tree():
		hook()
		update_grapple_hook_position()
	
	if hooked:
		grapple(delta)
	else:
		var move_dir = Input.get_axis("move_left", "move_right")
		if not is_dashing:
			custom_velocity.x = move_dir * MOVE_SPEED
			if move_dir != 0:
				dash_direction = Vector3(move_dir, 0, 0)
				facing_right = move_dir > 0
		
		if is_on_floor():
			y_velo = -0.1
			is_jumping = false
			if Input.is_action_just_pressed("jump"):
				y_velo = JUMP_FORCE
				is_jumping = true
		else:
			y_velo -= GRAVITY * delta
			y_velo = max(y_velo, -MAX_FALL_SPEED)
		
		if Input.is_action_just_pressed("dash") and not is_dashing and dash_direction != Vector3.ZERO:
			dash()
		
		if is_dashing:
			dash_timer += delta
			if dash_timer >= DASH_DURATION:
				is_dashing = false
				dash_timer = 0
		
		custom_velocity.y = y_velo
		custom_velocity.z = 0  # Restrict Z-axis movement
	
	velocity = custom_velocity
	move_and_slide()

func dash():
	is_dashing = true
	custom_velocity = dash_direction * DASH_FORCE

func hook():
	if Input.is_action_just_pressed("grapple"):
		if projectile == null:
			var character_middle_point = global_position
			
			var closest_raycast = find_closest_raycast(character_middle_point)
			
			if closest_raycast:
				var target_position = closest_raycast.get_collision_point()
				
				projectile = preload("res://projectile.tscn").instantiate()
				
				# Spawn the projectile at the character's middle point
				projectile.global_position = character_middle_point
				projectile.global_position.z = global_position.z
				
				get_parent().add_child(projectile)
				
				var direction = (target_position - projectile.global_position).normalized()
				direction.z = 0  # Restrict Z-axis direction
				projectile.linear_velocity = direction * projectile_speed
				latch_point = target_position
				
				# Update the character's facing direction based on the grapple direction
				facing_right = direction.x > 0
				
				projectile_path = []
				projectile_hit = false
				
				print("Using raycast: ", closest_raycast.name)
	else:
		hooked = false
		latch_point = null
		if projectile:
			projectile.queue_free()
			projectile = null

func find_closest_raycast(character_middle_point):
	var closest_raycast = null
	var closest_distance = INF
	
	for raycast in grapple_hook.get_children():
		if raycast is RayCast3D:
			raycast.global_position = character_middle_point
			raycast.force_raycast_update()
			
			if raycast.is_colliding():
				var distance = character_middle_point.distance_to(raycast.get_collision_point())
				if distance < closest_distance:
					closest_raycast = raycast
					closest_distance = distance
	
	return closest_raycast

func update_grapple_hook_position():
	grapple_hook.global_position = global_position

func _on_projectile_body_entered(body):
	if body != self and not hooked:
		hooked = true
		latch_point = projectile.global_position
		grapple(get_physics_process_delta_time())
		projectile.queue_free()
		projectile = null

func grapple(delta):
	if latch_point:
		var rope_vector = latch_point - global_position
		rope_vector.z = 0  # Restrict Z-axis movement
		var rope_direction = rope_vector.normalized()
		var rope_distance = rope_vector.length()
		
		if rope_distance > rope_length:
			var excess_distance = rope_distance - rope_length
			global_position += rope_direction * excess_distance
		
		var swing_direction = -rope_direction
		swing_direction.y = 0
		custom_velocity += swing_direction * swing_force
		
		custom_velocity.y -= gravity_force * delta
		custom_velocity.z = 0  # Restrict Z-axis movement
		
		var space_state = get_world_3d().direct_space_state
		var ray_params = PhysicsRayQueryParameters3D.new()
		ray_params.from = latch_point
		ray_params.to = global_position
		ray_params.collide_with_areas = true
		ray_params.collide_with_bodies = true
		
		var obstacle_collision = space_state.intersect_ray(ray_params)
		if obstacle_collision:
			var obstacle_position = obstacle_collision.position
			obstacle_position.z = global_position.z  # Set the Z-axis of the obstacle position to match the player's Z position
			var corner_positions = find_closest_corners(obstacle_position)
			var closest_corner = find_closest_point(corner_positions, global_position)
			latch_point = closest_corner

func find_closest_corners(obstacle_position):
	var corner_positions = []
	var unit_distance = 1.0
	
	for i in range(4):
		var corner_offset = Vector3.ZERO
		match i:
			0: # Top-left corner
				corner_offset = Vector3(-unit_distance, unit_distance, 0)
			1: # Top-right corner
				corner_offset = Vector3(unit_distance, unit_distance, 0)
			2: # Bottom-left corner
				corner_offset = Vector3(-unit_distance, -unit_distance, 0)
			3: # Bottom-right corner
				corner_offset = Vector3(unit_distance, -unit_distance, 0)
		
		var corner_position = obstacle_position + corner_offset
		corner_positions.append(corner_position)
	
	return corner_positions

func find_closest_point(points, target):
	var closest_point = null
	var closest_distance = INF
	
	for point in points:
		var distance = point.distance_to(target)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = point
	
	return closest_point
