extends CharacterBody3D

const MOVE_SPEED = 7
const JUMP_FORCE = 8.5
const GRAVITY = 20
const MAX_FALL_SPEED = 30
var y_velo = 0
var facing_right = true
var isJumping = false 

func _physics_process(delta):
	var move_dir = 0
	if Input.is_action_pressed("move_left"):
		move_dir -= 1
	if Input.is_action_pressed("move_right"):
		move_dir += 1
	
	velocity = Vector3(move_dir * MOVE_SPEED, y_velo, 0)
	up_direction = Vector3(0, 1, 0)
	move_and_slide()
	#move_and_slide(Vector3(move_dir * MOVE_SPEED, y_velo, 0), Vector3(0, 1, 0))
	
	
	var just_jump = false
	var grounded = is_on_floor()
	y_velo -= GRAVITY * delta
	
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
		
		
	if grounded:
		y_velo = 0.1
		if Input.is_action_just_pressed("jump"):
			y_velo = JUMP_FORCE
			just_jump = true


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
