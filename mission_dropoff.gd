class_name MissionZone
extends Area3D

var dropoff: bool = false
var receiving_trailer: RaycastVehicle

const TRAILER = preload("uid://ewkd4ux6upu1")

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var display_mesh: MeshInstance3D = $DisplayMesh


func spawn_trailer() -> RaycastVehicle:
	var trailer: RaycastVehicle = TRAILER.instantiate()
	add_child(trailer)
	trailer.position.y += 5
	
	return trailer


func set_dropoff(trailer: RaycastVehicle) -> void:
	dropoff = true
	receiving_trailer = trailer
	display_mesh.show()
