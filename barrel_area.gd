extends Area2D

@export var broken = false
@onready var barrel_animation: AnimatedSprite2D = $BarrelAnimation

func _ready() -> void:
	if not broken:
		barrel_animation.play("idle")
	else:
		barrel_animation.play("broken")  # If broken, keep it in the broken state

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword") and not broken:  # Check if not already broken
		broken = true
		barrel_animation.play("break")
