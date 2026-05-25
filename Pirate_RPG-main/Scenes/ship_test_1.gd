extends CharacterBody3D

@export var speed := 15.0
@export var rotation_speed := 1.5

@onready var ship_camera = $ShipCamera
@onready var exit_marker = $ExitMarker
@onready var interact_area = $Area3D

var player_inside = false
var player_ref = null
var player_nearby = null

func _ready():

	ship_camera.current = false

	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):

	# ENTER SHIP
	if player_nearby and Input.is_action_just_pressed("interact"):
		player_nearby.enter_ship(self)

	# SHIP CONTROL
	if !player_inside:
		return

	var forward_input = 0.0

	if Input.is_action_pressed("front"):
		forward_input += 1.0

	if Input.is_action_pressed("back"):
		forward_input -= 1.0

	velocity = -transform.basis.z * forward_input * speed

	var turn = Input.get_axis("right", "left")

	rotate_y(turn * rotation_speed * delta)

	move_and_slide()

	# EXIT SHIP
	if Input.is_action_just_pressed("interact"):
		player_ref.exit_ship()

func enter_ship(player):

	player_inside = true
	player_ref = player

	ship_camera.current = true

func exit_ship(player):

	player_inside = false

	player.global_transform.origin = exit_marker.global_transform.origin

	player.visible = true
	player.camera.current = true

func _on_body_entered(body):

	if body.name == "Player":
		player_nearby = body

func _on_body_exited(body):

	if body == player_nearby:
		player_nearby = null
