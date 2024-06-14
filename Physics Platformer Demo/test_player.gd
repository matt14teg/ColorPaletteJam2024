extends CharacterBody3D

# Constants
const MOVE_SPEED = 7.0
const JUMP_FORCE = 12.0
const GRAVITY = 30.0
const MAX_FALL_SPEED = 30.0
const DASH_FORCE = 30.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0
const ACCELERATION = 50.0
const DECELERATION = 70.0
const GRAPPLE_SPEED = 20.0
const GRAPPLE_RANGE = 10.0

# Variables
var y_velo = 0.0
var facing_right = true
var is_jumping = false
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var current_speed = 0.0
var is_grappling = false
var grapple_point = Vector3.ZERO
var grapple_ray = PhysicsRayQueryParameters3D.new()
var grapple_line = ImmediateMesh.new()

func _ready():
	# Set up the grapple line mesh
	grapple_line.surface_begin(Mesh.PRIMITIVE_LINES)
	grapple_line.surface_add_vertex(Vector3.ZERO)
	grapple_line.surface_add_vertex(Vector3.ZERO)
	grapple_line.surface_end()
	add_child(grapple_line)

func _physics_process(delta):
	var move_dir = 0.0
	if Input.is_action_pressed("move_left"):
		move_dir -= 1.0
		facing_right = false
	if Input.is_action_pressed("move_right"):
		move_dir += 1.0
		facing_right = true

	var grounded = is_on_floor()

	# Handle jumping
	if grounded and not is_jumping:
		if Input.is_action_just_pressed("jump"):
			y_velo = JUMP_FORCE
			is_jumping = true
	else:
		y_velo -= GRAVITY * delta

	# Limit the maximum fall speed
	y_velo = max(y_velo, -MAX_FALL_SPEED)

	# Update dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Handle dashing
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = DASH_DURATION
		current_speed = DASH_FORCE * (1.0 if facing_right else -1.0)
		dash_cooldown_timer = DASH_COOLDOWN

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			current_speed = 0.0

	# Handle grapple hook
	if Input.is_action_just_pressed("grapple") and not is_grappling:
		grapple_ray.from = global_transform.origin
		grapple_ray.to = global_transform.origin + global_transform.basis.z * GRAPPLE_RANGE
		grapple_ray.collision_mask = 1

		var grapple_result = get_world_3d().direct_space_state.intersect_ray(grapple_ray)
		if not grapple_result.is_empty():
			is_grappling = true
			grapple_point = grapple_result.position

	if is_grappling:
		var grapple_direction = (grapple_point - global_transform.origin).normalized()
		velocity = grapple_direction * GRAPPLE_SPEED
		if global_transform.origin.distance_to(grapple_point) < 1.0:
			is_grappling = false
	else:
		# Calculate the target speed based on movement direction
		var target_speed = move_dir * MOVE_SPEED

		# Apply smooth acceleration and deceleration when not dashing or grappling
		if not is_dashing:
			if move_dir != 0.0:
				current_speed = lerp(current_speed, target_speed, ACCELERATION * delta)
			else:
				current_speed = lerp(current_speed, 0.0, DECELERATION * delta)

		# Set the character's velocity
		velocity = Vector3(current_speed, y_velo, 0.0)

	# Move the character based on the calculated velocity
	move_and_slide()

	# Reset jumping flag when touching the ground
	if is_on_floor():
		is_jumping = false

	# Update the grapple line visualization
	if is_grappling:
		grapple_line.surface_get_arrays(0)[0][1] = grapple_point - global_transform.origin
	else:
		grapple_line.surface_get_arrays(0)[0][1] = global_transform.basis.z * GRAPPLE_RANGE
	grapple_line.surface_commit_arrays(0)
'''
DEFAULT CODE

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
'''
