extends RigidBody3D

var path = []
var hit = false

func _process(delta):
	# Update projectile path
	path.append(global_position)
	
	# Check for collisions
	if not hit and get_colliding_bodies().size() > 0:
		hit = true
		# Perform collision handling, e.g., apply force, destroy projectile, etc.
		queue_free()
