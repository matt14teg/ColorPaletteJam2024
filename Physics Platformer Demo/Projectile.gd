extends RigidBody3D

var speed = 10.0
signal collided(collision)

func _physics_process(delta):
	var collision = move_and_collide(linear_velocity.normalized() * speed * delta)
	if collision:
		emit_signal("collided", collision)
		visible = false
		linear_velocity = Vector3.ZERO
