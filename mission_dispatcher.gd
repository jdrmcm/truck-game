extends Node3D

var mission_zones: Array[MissionZone] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is MissionZone:
			mission_zones.append(child)
	
	generate_mission()


func generate_mission() -> void:
	if len(mission_zones) < 2:
		push_error("not enough mission zones! aborting mission dispatch...")
		return
	
	# pick 2 random mission zones
	mission_zones.shuffle()
	var start_zone: MissionZone = mission_zones[0]
	var end_zone: MissionZone = mission_zones[1]
	
	var trailer = start_zone.spawn_trailer()
	end_zone.set_dropoff(trailer)
