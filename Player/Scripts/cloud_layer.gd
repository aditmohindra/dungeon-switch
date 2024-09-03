extends ParallaxLayer

@export var base_cloud_speed : float = 15.0

func _ready():
	pass
	#print(main_character)
	#if main_character == null:
		#print("MainCharacter node not found!")

#
#func _process(delta):
	#if main_character.velocity != 0:
		## Determine the direction of the player (1 for right, -1 for left)
		#var direction = sign(main_character.velocity)
		#
		## Move the clouds in the opposite direction of the player's movement
		#self.motion_offset.x -= direction * base_cloud_speed * delta
