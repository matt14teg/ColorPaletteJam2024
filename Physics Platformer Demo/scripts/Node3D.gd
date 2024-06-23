extends Node3D

@export var time:float
@export var distance_from_center:float
@export_enum("Still", "Pacing", "Circular") var enemy_type:int

# Used for circular motion
var angle:float = 0.0
var speed:float = 1.5

var original_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	original_pos = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move()
	pass


func _physics_process(delta):
	move()


func move():
	# Don't include "Still" since we wouldn't do anything
	match enemy_type:
		"Pacing Horizontal": # Move back and forth
			pace_move(false)
			print("1")
		"Pacing Vertical": # Move back and forth
			pace_move(true)
			print("two")
		"Circular":
			print("circular")
			circular_move()

func pace_move(isVert):
	
	if isVert:
		
		pass
	else:
		pass
	pass
	

func circular_move():
	angle += speed * get_process_delta_time()
	var x_pos = cos(angle)
	var y_pos = sin(angle)
	position.x = distance_from_center * x_pos
	position.y = distance_from_center * y_pos

'''
Since enemies will not be spawned after the start of the scene, we will hide the enemy if it is hit.
If an enemy revives, we just reset the enemy location and set it to visible again. 
To prevent any errors with collision, we'll dissable the hitbox as well. 
'''
func is_hit():
	set_process(false)

