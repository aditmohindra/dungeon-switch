extends AnimatedSprite2D

func _ready():
	# Hide the default mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Hides the system cursor

func _process(delta):
	# Update the position of the cursor sprite to follow the mouse
	global_position = get_global_mouse_position()
