extends CharacterBody3D

@export var speed: float = 5.0
var target: Node = null

func _ready():
	# Find the player node in the scene
	target = get_node("Map/Ground/player")  # Adjust the path as needed

func _process(delta):
	if target:
		# Calculate the direction to the player
		var direction = (target.global_transform.origin - global_transform.origin).normalized()
		
		# Check the distance to the player
		var distance = global_transform.origin.distance_to(target.global_transform.origin)

		# If the player is close enough, move towards the player
		if distance < 5.0:  # Adjust this distance as needed
			move_and_collide(direction * speed * delta)

		# Rotate towards the player (you might want to use rotate_to for smoother rotation)
		look_at(target.global_transform.origin, Vector3(0, 1, 0))

		# If you want to attack the player, you can add your attack logic here
		# You might need to check the distance to the player and trigger attack animations

		# You can also check for line-of-sight, obstacles, and other conditions as needed
	else:
		# Handle the case when the player is not found
		pass
