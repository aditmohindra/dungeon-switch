extends Camera2D

@export var player: NodePath  # Drag and drop your player node here
@export var vertical_position: float = 0.0  # Fixed vertical position
@export var smoothing_speed_run_right: float = 20.0  # Smoothing speed when running right
@export var smoothing_speed_run_left: float = 15.0  # Smoothing speed when running left
@export var lerp_speed: float = 5.0  # Lerp speed for lookahead adjustment
@export var fast_lerp_speed: float = 10.0  # Faster lerp speed when stopping

var target_position: Vector2 = Vector2.ZERO
var current_lookahead_offset: float = 0.0

func _process(delta: float) -> void:
	if player:
		var player_node = get_node(player) as Node2D
		if player_node:
			var direction = sign(player_node.velocity.x)
			
			if direction > 0:
				# Player is moving to the right, apply a larger lookahead
				current_lookahead_offset = lerp(current_lookahead_offset, 100.0, fast_lerp_speed * delta)
				target_position = Vector2(player_node.position.x + current_lookahead_offset, vertical_position)
				position = position.lerp(target_position, smoothing_speed_run_right * delta)
			elif direction < 0:
				# Player is moving to the left, apply a smaller lookahead
				current_lookahead_offset = lerp(current_lookahead_offset, 0.0, lerp_speed * delta)
				target_position = Vector2(player_node.position.x + current_lookahead_offset, vertical_position)
				position = position.lerp(target_position, smoothing_speed_run_left * delta)
