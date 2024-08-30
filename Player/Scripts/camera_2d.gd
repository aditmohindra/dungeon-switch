extends Camera2D

@export var player: NodePath  # Drag and drop your player node here
@export var vertical_position: float = 0.0  # Fixed vertical position

func _process(delta: float) -> void:
	if player:
		var player_node = get_node(player) as Node2D
		if player_node:
			# Update camera's horizontal position to match the player's
			position.x = player_node.position.x
			# Keep the vertical position fixed
			position.y = vertical_position
