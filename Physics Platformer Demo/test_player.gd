extends CharacterBody3D

var speed = 450
var gravity2 = 100
const MOVE_SPEED = 7
const JUMP_FORCE = 8.5
const GRAVITY = 20
const MAX_FALL_SPEED = 30
const DASH_FORCE = 20
const DASH_DURATION = 0.2

var y_velo = 0
var facing_right = true
var is_jumping = false
var is_dashing = false
var dash_timer = 0
var dash_direction = Vector3.ZERO
var custom_velocity = Vector3()

var hook_pos = Vector3()
var hooked = false
var rope_length = 500
var current_rope_length

func _ready():
	current_rope_length = rope_length

func gravity():
	custom_velocity.y += gravity2

func _physics_process(delta):
	gravity()
	hook()

	if hooked:
		gravity()
		swing(delta)
		custom_velocity *= 0.974
		print("is hooked")
	else:
		var move_dir = Input.get_axis("move_left", "move_right")
		if not is_dashing:
			custom_velocity.x = move_dir * MOVE_SPEED
			if move_dir != 0:
				dash_direction = Vector3(move_dir, 0, 0)
		
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
		for raycast in grapplehook.get_children():
			if raycast is RayCast3D and raycast.is_colliding():
				hook_pos = raycast.get_collision_point()
				hooked = true
				current_rope_length = global_position.distance_to(hook_pos)
				break
			else:
				hooked = false
	else:
		hooked = false

	if Input.is_action_just_released("grapple"):
		hooked = false
		
func swing(delta):
	var radius = global_position - hook_pos
	if custom_velocity.length() < 0.01 or radius.length() < 10:
		return
	var angle = acos(radius.dot(custom_velocity) / (radius.length() * custom_velocity.length()))
	var rad_vel = cos(angle) * custom_velocity.length()
	custom_velocity += radius.normalized() * -rad_vel

	if global_position.distance_to(hook_pos) > current_rope_length:
		global_position = hook_pos + radius.normalized() * current_rope_length

	custom_velocity += (hook_pos - global_position).normalized() * 1500 * delta
