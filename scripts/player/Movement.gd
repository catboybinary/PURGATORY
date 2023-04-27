extends Node

@onready var player_logic: PlayerLogic = get_parent()
@onready var player: CharacterBody3D = get_parent().get_parent()
@export var rotatable : Node3D

@export var max_speed := 5
@export var jump_velocity := 7.0
@export var coyote := 0.1
@export var dash_speed := 7

var raw_decel: float = 0.2
var raw_accel: float = 1

# Get the global gravity from the project settings. RigidBody3D nodes also use this value.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var on_floor_coyote: bool
var coyote_time: float

var landing : bool
var crouching = false
var direction

var dash_direction: Vector3

signal land
signal dashed

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(
		&"move_left", &"move_right", 
		&"move_forward", &"move_backward"
	)
	
	var player_basis: Basis = rotatable.transform.basis
	direction = (player_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	player_logic.update_coyote(player.is_on_floor(), false)
	player_logic.vertical_state = player_logic.vertical_state_machine(player_logic.vertical_state)
	
	if (player.is_on_floor()):
		if landing:
			land.emit()
			landing = false
	else:
		if !landing:
			landing = true
	
	match player_logic.ability_state:
		PlayerLogic.AbilityState.DASHING:
			if (dash_direction == Vector3.ZERO):
				if direction == Vector3.ZERO: direction = rotatable.transform.basis*Vector3(0,0,-1)
				dashed.emit()
				dash_direction = direction
			player.velocity = dash(dash_direction)
		PlayerLogic.AbilityState.IDLE:
			dash_direction = Vector3.ZERO
			player.velocity = general_movement(player.velocity, direction, delta)
		
	player.move_and_slide()

func dash(direction: Vector3) -> Vector3:
	return direction * dash_speed
	
func general_movement(
	velocity: Vector3, 
	direction: Vector3, 
	delta: float
) -> Vector3:
	var new_vertical_velocity = get_vertical_velocity(velocity, delta)
	
	#flatten that
	velocity.y = 0
	
	var decel := -velocity.normalized() * raw_decel
	var accel := direction.normalized() * raw_accel
	
	if (velocity.length_squared() < decel.length_squared()):
		velocity = Vector3.ZERO
	else:
		velocity += decel
		
	velocity = (velocity + accel).limit_length(max_speed)
	velocity.y = new_vertical_velocity
	
	return velocity
	
func get_vertical_velocity(velocity: Vector3, delta: float) -> float:
	if (not player.is_on_floor()):
		velocity.y -= gravity * delta
		
	if (player_logic.coyote):
		if Input.is_action_just_pressed(&"jump") || player_logic.buffered_jump:
			player_logic.buffered_jump = false
			velocity.y = jump_velocity
			player_logic.update_coyote(false, true)

	return velocity.y
