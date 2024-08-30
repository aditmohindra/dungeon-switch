extends ParallaxLayer

@export var CLOUD_SPEED : float = -15.0

func _process(delta):
	self.motion_offset.x += CLOUD_SPEED * delta
