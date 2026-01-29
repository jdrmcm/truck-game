class_name RaycastVehicle
extends RigidBody3D

@export var wheels: Array[RaycastWheel]
@export var acceleration := 600.0
@export var max_speed := 20.0
@export var accel_curve: Curve
@export var tire_turn_speed: float = 1.0
@export var tire_max_turn_degrees := 40.0
@export var use_skid_marks := false
@export var steering_return_damping := 2.0

@export var skid_marks: Array[GPUParticles3D]

@onready var total_wheels := wheels.size()

var motor_input := 0
var handbrake := false
var is_slipping := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("brake"):
		handbrake = true
		is_slipping = true
	elif event.is_action_released("brake"):
		handbrake = false
		is_slipping = false
	motor_input = Input.get_action_strength("back") - Input.get_action_strength("forward")


func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)


func _basic_steering_rotation(wheel: RaycastWheel, delta: float) -> void:
	if not wheel.is_steer: return
	
	var raw_ratio := clampf(linear_velocity.length() / max_speed, 0.0, 1.0)
	var speed_ratio := clampf((raw_ratio - 0.5) / 0.9, 0.0, 1.0)
	var max_turn := lerpf(tire_max_turn_degrees, tire_max_turn_degrees * 0.3, speed_ratio)
	
	var turn_input := Input.get_axis("right", "left") * tire_turn_speed
	
	if turn_input:
		wheel.rotation.y = clampf(wheel.rotation.y + turn_input * delta,
			deg_to_rad(-max_turn), deg_to_rad(max_turn))
	else:
		var speed := linear_velocity.length()
		var speed_factor := clampf(speed / max_speed, 0.0, 1.0)
		wheel.rotation.y = move_toward(wheel.rotation.y, 0.0, steering_return_damping * speed_factor * delta)


func _physics_process(delta: float) -> void:
	var id := 0
	var grounded := false
	for wheel in wheels:
		wheel.apply_wheel_physics(self)
		_basic_steering_rotation(wheel, delta)
		
		
		# skid marks
		if use_skid_marks:
			skid_marks[id].global_position = wheel.get_collision_point() + Vector3.UP * 0.01
			skid_marks[id].look_at(skid_marks[id].global_position + global_basis.z)
			
			if not handbrake and wheel.grip_factor < 0.2:
				is_slipping = false
				skid_marks[id].emitting = false
			
			if handbrake and not skid_marks[id].emitting:
				skid_marks[id].emitting = true
		
		if wheel.is_colliding():
			grounded = true
		
		id += 1
