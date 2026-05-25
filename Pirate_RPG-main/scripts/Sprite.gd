extends CharacterBody3D

# --- Nodes ---
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D


# --- Movement ---
const WALK_SPEED    = 5.0
const SPRINT_SPEED  = 9.0
const JUMP_VELOCITY = 4.5

# --- Mouse Look ---
@export var mouse_sensitivity: float = 0.003

# --- Interaction ---
const INTERACT_DISTANCE = 5.0

# --- State ---
var current_direction: String = "front"
var controlling_ship = false
var current_ship = null

# ─────────────────────────────────────────
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ─────────────────────────────────────────
func _unhandled_input(event):
	if event is InputEventMouseMotion and !controlling_ship:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):

	if controlling_ship:
		return

	var input_dir = Input.get_vector(
		"left",
		"right",
		"front",
		"back"
	)

	var direction = (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED

	move_and_slide()

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if abs(input_dir.x) > abs(input_dir.y):
			current_direction = "right" if input_dir.x > 0 else "left"
		else:
			current_direction = "front" if input_dir.y > 0 else "back"
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	_update_animation()

func enter_ship(ship):

	controlling_ship = true
	current_ship = ship

	visible = false

	camera.current = false

	ship.enter_ship(self)
func exit_ship():

	if current_ship:
		current_ship.exit_ship(self)

	controlling_ship = false

	visible = true

	camera.current = true

	current_ship = null
# ─────────────────────────────────────────
func _update_animation() -> void:
	animated_sprite_3d.flip_h = false
	if velocity.length() > 0.1:
		animated_sprite_3d.speed_scale = 2.2 if Input.is_action_pressed("sprint") else 1.0
		match current_direction:
			"front": animated_sprite_3d.play("WALK_front")
			"back":  animated_sprite_3d.play("WALK_back")
			"left":  animated_sprite_3d.play("WALK_left")
			"right": animated_sprite_3d.play("WALK_right")
	else:
		animated_sprite_3d.speed_scale = 1.0
		match current_direction:
			"front": animated_sprite_3d.play("IDLE_front")
			"back":  animated_sprite_3d.play("IDLE_back")
			"left":  animated_sprite_3d.play("IDLE_left")
			"right": animated_sprite_3d.play("IDLE_right")
