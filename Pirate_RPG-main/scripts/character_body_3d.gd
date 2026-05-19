extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get gravity from project settings for consistent physics
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add gravity if not on the floor
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction (WASD/Arrows)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Convert 2D input to 3D movement (X and Z axes)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide() # Executes movement and handles collisions
