class_name RaycastWheel
extends RayCast3D

@export_group("Wheel properties")
@export var spring_strength := 7500
# d=z(2Sqrt[k*m]), z=0.1, m=1, k=100 is the formula for optimal spring damping. K is spring strength and M is car mass in kg.
# Z value should be between 0.1-1.0. 0.1-0.2 for more arcadey feel, 0.2-1.0 for more realistic.
@export var spring_damping  := 1400
@export var rest_dist       := 0.7
@export var over_extend     := 0.0
@export var wheel_radius    := 0.8
@export var z_traction      := 0.5

@export_category("Motor")
@export var is_motor := false
@export var is_steer := false
@export var grip_curve: Curve

@onready var wheel: Node3D = get_child(0)

var engine_force := 0.0
var grip_factor  := 0.0


func _ready() -> void:
	target_position.y = -(rest_dist + wheel_radius + over_extend)


func apply_wheel_physics(car: RaycastVehicle) -> void:
	force_raycast_update()
	target_position.y = -(rest_dist + wheel_radius + over_extend)
	
	
	# rotate wheel mesh
	var forward_dir     := global_basis.z
	var vel             := forward_dir.dot(car.linear_velocity)
	wheel.rotate_x( (vel * get_physics_process_delta_time()) / wheel_radius )
	
	
	if not is_colliding(): return
	# this line onwards the wheel is colliding
	
	
	var contact         := get_collision_point()
	var spring_len      := global_position.distance_to(contact) - wheel_radius
	var offset          := rest_dist - spring_len
	
	wheel.position.y = -spring_len
	contact = wheel.global_position
	var force_pos       := contact - car.global_position
	
	
	# spring forces
	var spring_force    := spring_strength * offset
	var tire_vel        := car._get_point_velocity(contact)
	var spring_damp_f   := spring_damping * global_basis.y.dot(tire_vel)
	
	var y_force         := (spring_force - spring_damp_f) * get_collision_normal()
	
	
	# accelerations
	if is_motor and car.motor_input:
		var speed_ratio := vel / car.max_speed
		var accel       := car.accel_curve.sample_baked(speed_ratio)
		var accel_force := -forward_dir * car.acceleration * car.motor_input * accel
		car.apply_force(accel_force, force_pos)
	
	
	# tire x traction (steering)
	var steering_x_vel  := global_basis.x.dot(tire_vel)
	
	grip_factor          = absf(steering_x_vel/tire_vel.length())
	if is_nan(grip_factor): grip_factor = 0
	var x_traction      := grip_curve.sample_baked(grip_factor)
	
	if not car.handbrake and grip_factor < 0.2:
		car.is_slipping = false
	if car.handbrake:
		x_traction = 0.01
	elif car.is_slipping:
		x_traction = 0.1
	
	var gravity         := -car.get_gravity().y
	var x_force          = -global_basis.x * steering_x_vel * x_traction * ((car.mass * gravity) / car.total_wheels)
	
	# F = M * dV/T
	#var desired_accel := (steering_x_vel * x_traction) / get_physics_process_delta_time()
	#var x_force := -steer_side_dir * desired_accel * (mass/4.0)
	
	
	# tire z traction (rolling resistance)
	var f_vel           := forward_dir.dot(tire_vel)
	var normal_force    := (car.mass * gravity) / car.total_wheels
	var z_force          = -forward_dir * sign(f_vel) * z_traction * normal_force
	
	
	# apply forces
	car.apply_force(y_force, force_pos)
	car.apply_force(x_force, force_pos)
	car.apply_force(z_force, force_pos)
