extends Node3D

# Define the distance threshold for playing the animation
var play_distance = 5.0

# Reference to the player node (assuming it's an instance of the "test_player" scene)
@onready var player = $"../CharacterBody3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player and is_instance_valid(player):
		# Calculate the distance between the player and this node
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		
		# Check if the player is within the play distance
		if distance <= play_distance:
			# Play the "wigglewormanimated" animation on the player's AnimationPlayer
			print("distance is in play distance")
			var animation_player = player.get_node_or_null("AnimationPlayer")
			if animation_player and not animation_player.is_playing("wigglewormanimated"):
				print("play anim")
				animation_player.play("wigglewormanimated")
		else:
			# Stop the animation if the player is out of distance
			var animation_player = player.get_node_or_null("AnimationPlayer")
			if animation_player and animation_player.is_playing("wigglewormanimated"):
				animation_player.stop()
