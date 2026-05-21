extends RigidBody3D
class_name InteractiveShip

# --- Buoyancy ---
@export var water_drag         := 0.15
@export var water_angular_drag := 0.15
const WATER_HEIGHT             := 20.5

# --- Driving ---
const SHIP_SPEED_FORCE  = 2500.0
const SHIP_TURN_TORQUE  = 1500.0

# --- Seat / Exit markers (drag in via Inspector) ---
@export var seat_position_node: Marker3D
@export var exit_position_node: Marker3D

# --- State ---
var is_being_driven:   bool              = false
var driver_reference:  CharacterBody3D   = null
var submerged:         bool              = false

# ─────────────────────────────────────────
func _ready() -> void:
	linear_damp_mode  = RigidBody3D.DAMP_MODE_COMBINE
	angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
	axis_lock_angular_x = true
	axis_lock_angular_z = true

# ─────────────────────────────────────────
func _physics_process(_delta: float) -> void:
	# ── Buoyancy ──
	submerged = false
	if global_position.y <= WATER_HEIGHT:
		submerged = true
		global_position.y = WATER_HEIGHT
		if linear_velocity.y < 0:
			linear_velocity.y = 0
		linear_damp  = 5.0
		angular_damp = 5.0
	else:
		linear_damp  = 0.0
		angular_damp = 0.0

	# ── Ship controls (only when being driven) ──
	if is_being_driven:
		var input_dir      := Input.get_vector("left", "right", "front", "back")
		var forward        := -transform.basis.z.normalized()

		# Forward / backward thrust
		apply_central_force(forward * (-input_dir.y * SHIP_SPEED_FORCE))

		# Left / right turn
		apply_torque(Vector3(0, -input_dir.x * SHIP_TURN_TORQUE, 0))

		# Exit ship with E
		if Input.is_action_just_pressed("interact"):
			exit_ship()

# ─────────────────────────────────────────
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity  *= 1.0 - water_drag
		state.angular_velocity *= 1.0 - water_angular_drag

# ─────────────────────────────────────────
func enter_ship(player: CharacterBody3D) -> void:
	is_being_driven  = true
	driver_reference = player
	sleeping         = false

	player.driving_vehicle = self
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.velocity = Vector3.ZERO

	# Move player to seat
	if seat_position_node != null:
		player.global_position = seat_position_node.global_position
	else:
		player.global_position = global_position

	# Hide sprite while driving
	if player.has_node("AnimatedSprite3D"):
		player.get_node("AnimatedSprite3D").visible = false

# ─────────────────────────────────────────
func exit_ship() -> void:
	is_being_driven = false

	if driver_reference == null:
		return

	var player       = driver_reference
	driver_reference = null

	player.driving_vehicle = null

	# Move player to exit point
	if exit_position_node != null:
		player.global_position = exit_position_node.global_position
	else:
		player.global_position = global_position + Vector3(2, 0, 0)

	player.velocity = Vector3.ZERO

	# Show sprite again
	if player.has_node("AnimatedSprite3D"):
		player.get_node("AnimatedSprite3D").visible = true

	player.visible = true
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
