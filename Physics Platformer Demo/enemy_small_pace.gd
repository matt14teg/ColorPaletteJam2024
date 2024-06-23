extends Node3D

@export var time:float
@export var distance_from_center:float



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	pass
	


func calculate_distance_from_center():
	
	
	
	pass

'''
Since enemies will not be spawned after the start of the scene, we will hide the enemy if it is hit.
If an enemy revives, we just reset the enemy location and set it to visible again. 
To prevent any errors with collision, we'll dissable the hitbox as well. 
'''
func is_hit():
	set_process(false)
	
	
