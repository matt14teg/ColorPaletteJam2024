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

func _physics_process(delta):
	gravity()
	hook()
	
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
	
	velocity = custom_velocity
	move_and_slide()

func dash():
	is_dashing = true
	custom_velocity = dash_direction * DASH_FORCE

func hook():
	if Input.is_action_pressed("grapple"):
		var grapplehook = get_node("Grapplehook")
		var camera = get_viewport().get_camera_3d()
		var mouse_position = get_viewport().get_mouse_position()
		
		var closest_raycast = null
		var closest_distance = INF
		
		for raycast in grapplehook.get_children():
			if raycast is RayCast3D:
				var screen_pos = camera.unproject_position(raycast.global_transform.origin)
				var distance = screen_pos.distance_to(mouse_position)
				
				# Check if the raycast is on the allowed side based on the mouse position
				var is_allowed_side = false
				if facing_right and raycast.name in ["GrappleRaycast", "GrappleRaycast2", "GrappleRaycast5", "GrappleRaycast6"]:
					is_allowed_side = true
				elif not facing_right and raycast.name in ["GrappleRaycast3", "GrappleRaycast4", "GrappleRaycast7", "GrappleRaycast8"]:
					is_allowed_side = true
				
				if is_allowed_side and distance < closest_distance and raycast.is_colliding():
					closest_raycast = raycast
					closest_distance = distance
		
		if closest_raycast:
			hook_pos = closest_raycast.get_collision_point()
			grapple_direction = (hook_pos - global_position).normalized()
			grapple_timer = 0
			hooked = true
			swing_angle = 0.0
	else:
		hooked = false

func grapple(delta):
	grapple_timer += delta
	
	if grapple_timer < grapple_duration:
		# Calculate the swing motion
		swing_angle += SWING_SPEED * delta
		
		var swing_offset = Vector3(
			sin(swing_angle) * SWING_RADIUS,
			-cos(swing_angle) * SWING_RADIUS,
			0
		)
		
		var start_pos = hook_pos
		var end_pos = hook_pos + swing_offset
		
		custom_velocity = (end_pos - global_position) * GRAPPLE_SPEED
	else:
		custom_velocity = grapple_direction * GRAPPLE_SPEED
		hooked = false
