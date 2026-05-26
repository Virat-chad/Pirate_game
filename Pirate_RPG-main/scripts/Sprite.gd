extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var camera: Camera3D = $Camera3D

const WALK_SPEED    = 5.0
const SPRINT_SPEED  = 9.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity: float = 0.003

const INTERACT_DISTANCE = 12.0

var current_direction: String = "front"
var driving_vehicle: RigidBody3D = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	# Keep player glued to seat while driving
	if driving_vehicle != null and driving_vehicle.seat_position_node != null:
		global_position = driving_vehicle.seat_position_node.global_position

func _physics_process(delta: float) -> void:

	if driving_vehicle != null:
		velocity = Vector3.ZERO
		if driving_vehicle.seat_position_node != null:
			global_position = driving_vehicle.seat_position_node.global_position
		return

	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("interact"):
		print("E pressed, looking for ships...")
		print("Ships in group: ", get_tree().get_nodes_in_group("ships").size())
		_try_enter_ship()
   


	
	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	var input_dir := Input.get_vector("left", "right", "front", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

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


func _try_enter_ship() -> void:
	var nearest_ship = null
	var nearest_dist := INTERACT_DISTANCE
	for body in get_tree().get_nodes_in_group("ships"):
		var flat_player = Vector2(global_position.x, global_position.z)
		var flat_ship = Vector2(body.global_position.x, body.global_position.z)
		var dist = flat_player.distance_to(flat_ship)
		print("Flat distance to ship: ", dist)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_ship = body
	if nearest_ship != null:
		nearest_ship.enter_ship(self)
	else:
		print("Too far!")


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
