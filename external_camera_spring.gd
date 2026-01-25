extends SpringArm3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if !$ExternalCamera.current:
		return
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * Globals.camera_sensitivity
		rotation.x -= event.relative.y * Globals.camera_sensitivity
