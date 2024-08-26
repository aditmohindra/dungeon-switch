extends CharacterBody2D
class_name Player

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

@onready var main_character: AnimatedSprite2D = $MainCharacter
@onready var side_character: AnimatedSprite2D = $SideCharacter

var active_character: AnimatedSprite2D

func _ready() -> void:
	# Set the initial active character
	active_character = main_character
	side_character.visible = false  # Hide the side character initially

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle basic attack
	if Input.is_action_just_pressed("basic_attack"):
		play_basic_attack()
		return

	# Handle character switching
	if Input.is_action_just_pressed("switch"):
		switch_character()

	# Handle movement
	handle_movement()

	# Apply movement
	move_and_slide()

# Function to handle character movement
func handle_movement():
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite depending on direction
	if direction > 0:
		active_character.flip_h = false
	elif direction < 0:
		active_character.flip_h = true
	if is_on_floor():
		if direction == 0:
			active_character.play("idle")
		else:
			active_character.play("walk")
	else:
		active_character.play("jump")

	# Apply horizontal movement
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# Function to play the basic attack
func play_basic_attack():
	active_character.play("basic_attack")

# Function to switch the active character
func switch_character():
	if active_character == main_character:
		active_character = side_character
		main_character.visible = false
		side_character.visible = true	
	else:
		active_character = main_character
		side_character.visible = false
		main_character.visible = true
