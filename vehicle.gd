extends RaycastVehicle

@onready var external_camera: Camera3D = $ExternalCameraSpring/ExternalCamera
@onready var cab_camera: Camera3D = $CabCamera
@onready var hitch: Generic6DOFJoint3D = $Hitch

var third_person: bool = false
var attached_trailer: RaycastVehicle
var nearby_trailer: RaycastVehicle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_camera"):
		third_person = !third_person
		if third_person:
			external_camera.make_current()
		else:
			cab_camera.make_current()
	
	if Input.is_action_just_pressed("attach_trailer"):
		if !nearby_trailer:
			return
		
		if attached_trailer:
			attach_trailer(false, attached_trailer)
		else:
			attach_trailer(true, nearby_trailer)


func attach_trailer(attach: bool, trailer: RaycastVehicle = null):
	if attach:
		trailer.lock_rotation = false
		trailer.global_position = hitch.global_position
		trailer.rotation.z = 0
		trailer.attached = true
		rotation.z = 0
		attached_trailer = trailer
		hitch.node_a = self.get_path()
		hitch.node_b = trailer.get_path()
	else:
		trailer.lock_rotation = true
		trailer.attached = false
		trailer.rotation.z = 0
		trailer.rotation.x = 0
		attached_trailer = null
		hitch.node_a = NodePath()
		hitch.node_b = NodePath()


func _on_hitch_area_entered(area: Area3D) -> void:
	if area.is_in_group("trailer_connection"):
		nearby_trailer = area.get_parent()


func _on_hitch_area_exited(area: Area3D) -> void:
	if area.is_in_group("trailer_connection"):
		nearby_trailer = null
