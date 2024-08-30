extends Camera2D

@export var player: NodePath  # Drag and drop your player node here
@export var vertical_position: float = 0.0  # Fixed vertical position
@export var smoothing_speed: float = 4.0  # Adjust the smoothing speed to your preference

func _process(delta: float) -> void:
	if player:
		var player_node = get_node(player) as Node2D
		if player_node:
			# Target position where the camera should move
			var target_position = Vector2(player_node.position.x, vertical_position)
			
			# Smoothly interpolate the camera's position towards the target position
			position = position.lerp(target_position, smoothing_speed * delta)
			
			
			
