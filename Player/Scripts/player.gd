extends CharacterBody2D

# Define character states
enum State { IDLE, RUNNING, JUMPING }

@export var SPEED : float = 200.0
@export var JUMP_VELOCITY = -250.0  # Jump force

@onready var main_character: AnimatedSprite2D = $MainCharacter

var state = State.IDLE  # Start with the idle state

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle movement and state transitions
	var direction := Input.get_axis("move_left", "move_right")
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMPING)
		update_animation()

	# Update movement and state
	if direction != 0:
		velocity.x = direction * SPEED
		flip_sprite(direction)
		if is_on_floor():
			update_animation()
			change_state(State.RUNNING)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and velocity.x == 0:
			update_animation()
			change_state(State.IDLE)

	# Apply movement
	move_and_slide()

	# Update animation based on the current state
	update_animation()

func flip_sprite(direction: float) -> void:
	if direction > 0:
		main_character.flip_h = false
	elif direction < 0:
		main_character.flip_h = true

func update_animation() -> void:
	match state:
		State.IDLE:
			if main_character.animation != "idle":
				main_character.play("idle")
		State.RUNNING:
			if main_character.animation != "run":
				main_character.play("run")
		State.JUMPING:
			if main_character.animation != "jump":
				main_character.play("jump")

# Function to change state and print when the state changes
func change_state(new_state: int) -> void:
	if state != new_state:
		state = new_state
		print("State changed to: ", state)

# Optionally, reset the state when landing
func _on_AnimatedSprite2D_animation_finished():
	if is_on_floor():
		if velocity.x == 0:
			change_state(State.IDLE)
			update_animation()
		else:
			change_state(State.RUNNING)
			update_animation()
