extends VehicleBody3D

@export var max_steer = 0.6
@export var engine_power = 200
@export var steer_rate = 0.45
@export var brake_force = 8
@export var attached_trailer: Trailer

@onready var steering_wheel: MeshInstance3D = $tractor/Cube/steering_wheel
@onready var external_camera: Camera3D = $ExternalCameraSpring/ExternalCamera
@onready var cab_camera: Camera3D = $CabCamera
@onready var hitch: Generic6DOFJoint3D = $Hitch/Joint

var third_person: bool = false
var handbrake: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


var steering_value
@onready var steering_wheel_identity = steering_wheel.transform.basis
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering_value = move_toward(steering, Input.get_axis("right", "left") * max_steer, delta * steer_rate)
	
	steering = steering_value
	#steering_wheel.rotate_object_local(Vector3.DOWN, steering_value * 0.05)
	
	steering_wheel.transform.basis = steering_wheel_identity
	steering_wheel.transform.basis = steering_wheel.transform.basis.rotated(steering_wheel.transform.basis.y.normalized(), -steering_value * 5)
	engine_force = Input.get_axis("back", "forward") * engine_power
	
	brake = int(handbrake) * brake_force
	
	if attached_trailer:
		attached_trailer.toggle_brake_lights(brake > 0 or engine_force < 0)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_camera"):
		third_person = !third_person
		if third_person:
			external_camera.make_current()
		else:
			cab_camera.make_current()
	
	if Input.is_action_just_pressed("brake"):
		handbrake = !handbrake
	
	if Input.is_action_just_pressed("attach_trailer"):
		if !nearby_trailer:
			return
		
		if attached_trailer:
			attach_trailer(false, attached_trailer)
		else:
			attach_trailer(true, nearby_trailer)


func attach_trailer(attach: bool, trailer: Trailer = null):
	if attach:
		trailer.freeze = false
		trailer.global_position = hitch.global_position
		trailer.rotation.z = 0
		rotation.z = 0
		attached_trailer = trailer
		hitch.node_a = self.get_path()
		hitch.node_b = trailer.get_path()
	else:
		trailer.freeze = true
		attached_trailer = null
		hitch.node_a = NodePath()
		hitch.node_b = NodePath()


var nearby_trailer: Trailer
func _on_hitch_area_entered(area: Area3D) -> void:
	if area.is_in_group("trailer_connection"):
		nearby_trailer = area.get_parent()


func _on_hitch_area_exited(area: Area3D) -> void:
	if area.is_in_group("trailer_connection"):
		nearby_trailer = null
