class_name Player
extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_velocity: float = -250.0
@export var slide_velocity: float = 370.0  # Speed during slide
@export var gravity_scale: float = 1.0  # Normal gravity scale
@export var fall_gravity_scale: float = 1.43  # Increased gravity scale when falling
@export var slide_duration: float = 0.05  # Shorter slide duration

@onready var main_character: AnimatedSprite2D = $MainCharacter

var animation_locked: bool = false
var can_attack: bool = false
var direction: float = 0.0
var sword_unsheathed: bool = false  # Variable to track if the sword is unsheathed
var slide_timer: float = 0.0  # Timer to track slide duration

enum States {IDLE, WALK, JUMP, SLIDE, SWORDED, UNSWORDED}

var state_names = {
	States.IDLE: "IDLE",
	States.WALK: "WALK",
	States.JUMP: "JUMP",
	States.SLIDE: "SLIDE",
	States.SWORDED: "SWORDED",
	States.UNSWORDED: "UNSWORDED"
}

var state = States.IDLE
var prev_state = States.IDLE

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
	
	# Handle Slide
	handle_slide(delta)
	
	# Handle stance switching
	handle_stance()

	# Moves the body based on velocity
	move_and_slide()
	
	# Updates character animation
	update_animation()
	
	# Updates facing direction
	update_facing_direction()

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
		if state != States.SLIDE:  # Prevent walking while sliding
			change_state(States.WALK)
			velocity.x = direction * speed
	else:
		if sword_unsheathed:
			change_state(States.SWORDED)
		else:
			if is_on_floor():
				change_state(States.IDLE)
		velocity.x = move_toward(velocity.x, 0, speed)
	
	return state
	
func handle_slide(delta: float) -> States:
	if Input.is_action_just_pressed("slide") and is_on_floor() and not animation_locked and state == States.WALK:
		# Start the slide
		change_state(States.SLIDE)
		animation_locked = true
		slide_timer = slide_duration
		velocity.x = ( direction * slide_velocity ) * 0.53
		main_character.play("slide")
	elif state == States.SLIDE:
		# Continue sliding with consistent speed
		slide_timer -= delta
		if slide_timer <= 0:
			# End the slide abruptly when the timer runs out
			animation_locked = false
			velocity.x = 0  # Stop horizontal movement at the end of the slide
			if is_on_floor():
				change_state(States.IDLE)
			else:
				change_state(States.JUMP)
	return state


func handle_stance() -> States:
	if Input.is_action_just_pressed("unsheathe") and not animation_locked and direction == 0:
		if sword_unsheathed:
			change_state(States.UNSWORDED)
			main_character.play("sheathe")
			animation_locked = true
			# print("Sheathed...")
			can_attack = false
			sword_unsheathed = false
		else:
			change_state(States.SWORDED)
			main_character.play("unsheathe")
			animation_locked = true
			# print("Unsheathed!")
			can_attack = true
			sword_unsheathed = true
	
	return state
	
func update_animation():
	if animation_locked:
		return  # Prevent any other animation from playing if an animation is locked

	match state:
		States.IDLE:
			if is_on_floor() and direction == 0:
				if sword_unsheathed:
					main_character.play("idle_sword")
				else:
					main_character.play("idle")
		States.WALK:
			if is_on_floor() and direction != 0:
				if sword_unsheathed:
					main_character.play("walk_sworded")
				else:
					main_character.play("walk")
		States.JUMP:
			if not is_on_floor():
				main_character.play("jump")
		States.SLIDE:
			main_character.play("slide")
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

func change_state(new_state: States) -> void:
	if state != new_state:
		prev_state = state
		state = new_state
		print("State changed to: ", state_names[state])


func _on_main_character_animation_finished():
	animation_locked = false
	
	# Ensure the correct idle animation plays after the sheathe or unsheathe animation
	if sword_unsheathed:
		main_character.play("idle_sword")
	else:
		main_character.play("idle")
