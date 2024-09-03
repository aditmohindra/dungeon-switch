class_name Player
extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_velocity: float = -250.0
@export var slide_velocity: float = 370.0  # Speed during slide
@export var dash_distance: float = 50.0  # Distance for dash
@export var dash_cooldown: float = 0.5  # Cooldown time between dashes
@export var gravity_scale: float = 1.0  # Normal gravity scale
@export var fall_gravity_scale: float = 1.43  # Increased gravity scale when falling
@export var slide_duration: float = 0.05  # Shorter slide duration
@export var combo_timeout: float = 0.5  # Time window to chain the combo
@export var can_attack: bool = false # Can attack?

@onready var combo_timer: Timer = $ComboTimer
@onready var main_character: AnimatedSprite2D = $MainCharacter

var animation_locked: bool = false
var direction: float = 0.0
var sword_unsheathed: bool = false  # Variable to track if the sword is unsheathed
var slide_timer: float = 0.0  # Timer to track slide duration
var dash_cooldown_timer: float = 0.0  # Timer to track dash cooldown
var combo_index: int = 0  # Tracks the current step in the combo
var is_attacking: bool = false  # Tracks whether an attack is in progress

@onready var slash: CollisionShape2D = $AttackArea/Slash

enum States {IDLE, WALK, JUMP, SLIDE, DASH, SWORDED, UNSWORDED, ATTACK}

var state_names = {
	States.IDLE: "IDLE",
	States.WALK: "WALK",
	States.JUMP: "JUMP",
	States.SLIDE: "SLIDE",
	States.DASH: "DASH",
	States.SWORDED: "SWORDED",
	States.UNSWORDED: "UNSWORDED",
	States.ATTACK: "ATTACK"
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
	
	# Handle Dash
	handle_dash(delta)

	# Handle stance switching
	handle_stance()
	
	# Handle attacking
	slash.set_deferred("disabled", true)
	handle_attack()

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
		if state != States.SLIDE and state != States.DASH:  # Prevent walking while sliding or dashing
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
		velocity.x = direction * slide_velocity * 0.53
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

func handle_dash(delta: float) -> States:
	dash_cooldown_timer -= delta
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not animation_locked:
		# Start the dash
		change_state(States.DASH)
		animation_locked = true
		dash_cooldown_timer = dash_cooldown
		# Teleport the player forward
		position.x += direction * dash_distance
		main_character.play("dash")  # Replace with your dash animation if you have one
		print("Dashing")
		animation_locked = false  # Unlock immediately after the dash
		if is_on_floor():
			change_state(States.IDLE)
		else:
			change_state(States.JUMP)
	return state

func handle_stance() -> States:
	if Input.is_action_just_pressed("unsheathe") and not animation_locked and direction == 0:
		if sword_unsheathed:
			change_state(States.UNSWORDED)
			speed += 30.0
			main_character.play("sheathe")
			animation_locked = true
			# print("Sheathed...")
			can_attack = false
			sword_unsheathed = false
		else:
			change_state(States.SWORDED)
			speed = 150.0
			main_character.play("unsheathe")
			animation_locked = true
			# print("Unsheathed!")
			can_attack = true
			sword_unsheathed = true
	
	return state


func handle_attack() -> States:
	if Input.is_action_just_pressed("basic_attack") and can_attack and state != States.WALK:
		if state != States.ATTACK:
			change_state(States.ATTACK)
			slash.set_deferred("disabled", false)  # Enable the collision shape at the start of the attack
			play_attack_animation()
		elif state == States.ATTACK and main_character.is_playing():
			# Ensure the current animation has progressed sufficiently before starting the next one
			if main_character.get_frame() >= main_character.sprite_frames.get_frame_count(main_character.animation) / 1.7:
				play_attack_animation()
		return state  # Prevent other states from being evaluated

	# Check if the animation has finished
	if state == States.ATTACK and not main_character.is_playing():
		if combo_timer.time_left > 0:
			play_attack_animation()  # Continue combo if timer is active
		else:
			reset_attack_state()  # Reset to the appropriate state after combo ends
	
	return state

	
func play_attack_animation():
	# print("ATTACK!")
	if combo_index == 0:
		main_character.play("basic_attack")
	elif combo_index == 1:
		main_character.play("basic_attack_2")
	elif combo_index == 2:
		main_character.play("basic_attack_3")

	combo_index = (combo_index + 1) % 3  # Cycle through the combo animations
	combo_timer.start(combo_timeout)  # Start/reset the combo timer
	animation_locked = true  # Lock the animation until it finishes


func reset_attack_state():
	animation_locked = false
	combo_index = 0
	slash.set_deferred("disabled", false)  # Disable the collision shape after the attack ends
	if is_on_floor():
		change_state(States.IDLE if not sword_unsheathed else States.SWORDED)
	else:
		change_state(States.JUMP)


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
		States.DASH:
			main_character.play("dash")  # Play dash animation if you have one
		States.SWORDED:
			main_character.play("idle_sword")
		States.ATTACK:
			pass

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
