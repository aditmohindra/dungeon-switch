class_name Player
extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_velocity: float = -250.0
@export var gravity_scale: float = 1.0  # Normal gravity scale
@export var fall_gravity_scale: float = 1.43  # Increased gravity scale when falling

@onready var main_character: AnimatedSprite2D = $MainCharacter

var animation_locked: bool = false
var can_attack: bool = false
var direction: float = 0.0

enum States {IDLE, WALK, JUMP, SWORDED, UNSWORDED}

var state = States.IDLE

func add_gravity(delta: float) -> void:
	if not is_on_floor():
		if velocity.y > 0:  # Falling
			velocity += get_gravity() * fall_gravity_scale * delta
		else:  # Rising (jumping)
			velocity += get_gravity() * gravity_scale * delta

func _physics_process(delta: float) -> void:
	# Add gravity
	add_gravity(delta)

	# Handle Jump
	handle_jump()
	
	# Handle Movement
	handle_movement()
	
	# Handle stance switching
	handle_stance()

	# Moves the body based on velocity
	move_and_slide()
	
	# Updates character animation
	update_animation()
	
	# Updates facing direction
	update_facing_direction()

func update_animation():
	if animation_locked:
		return  # Prevent any other animation from playing if an animation is locked

	match state:
		States.IDLE:
			if is_on_floor() and direction == 0:
				main_character.play("idle")
		States.WALK:
			if is_on_floor() and direction != 0:
				main_character.play("walk")
		States.JUMP:
			if not is_on_floor():
				main_character.play("jump")
		States.SWORDED:
			main_character.play("idle_sword")

func update_facing_direction():
	if direction > 0:
		main_character.flip_h = false
	elif direction < 0:
		main_character.flip_h = true

func jump() -> void:
	velocity.y = jump_velocity
	main_character.play("jump")
	animation_locked = true

func handle_jump() -> States:
	if Input.is_action_just_pressed("jump") and not animation_locked:
		if is_on_floor():
			# Normal jump from floor
			change_state(States.JUMP)
			jump()
	elif not is_on_floor():
		# If the player is in the air, ensure the state is JUMP
		change_state(States.JUMP)
	return state

func handle_movement() -> States:
	if animation_locked:
		return state  # Prevent movement if an animation is locked

	direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		change_state(States.WALK)
		velocity.x = direction * speed
	else:
		if state == States.SWORDED:
			change_state(States.SWORDED)
		else:
			if is_on_floor():
				change_state(States.IDLE)
		velocity.x = move_toward(velocity.x, 0, speed)
	
	return state

func handle_stance() -> States:
	if Input.is_action_just_pressed("unsheathe") and not animation_locked:
		# Stop all movement and prevent further input
		velocity = Vector2.ZERO
		direction = 0
		
		if state == States.SWORDED:
			change_state(States.UNSWORDED)
			main_character.play("sheathe")
			animation_locked = true
			print("Sheathed...")
			can_attack = false
		else:
			change_state(States.SWORDED)
			main_character.play("unsheathe")
			animation_locked = true
			print("Unsheathed!")
			can_attack = true
	
	return state

func change_state(new_state: States) -> void:
	if state != new_state:
		state = new_state
		print(str(state))  # Print the actual enum name

func _on_main_character_animation_finished():
	animation_locked = false
	
	# Ensure the correct idle animation plays after the sheathe or unsheathe animation
	if state == States.SWORDED:
		main_character.play("idle_sword")
	elif state == States.UNSWORDED or state == States.IDLE:
		main_character.play("idle")
