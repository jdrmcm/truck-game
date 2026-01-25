class_name Trailer
extends VehicleBody3D

@export var brake_lights: Array[SpotLight3D]


func toggle_brake_lights(state: bool):
	for light in brake_lights:
		light.visible = state


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
