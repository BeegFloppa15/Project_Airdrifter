extends Area3D

# Will match the wind direction of the area
var wind_direction: Vector3
# A reference to the player's glider, which will be initialized when it enters the area for the first time
var player_glider: ElytraGlider
# If true, a windsock will appear and indicate wind direction
@export var debug_cloth: bool = true

func _ready() -> void:
	# By default, physics process will be deactivated.
	set_physics_process(false)
	
	var wind_marker = get_node(wind_source_path)
	
	# Rotating a unit vector to point in the -Z direction of the wind marker
	wind_direction = Vector3(0, 0, 1).rotated(Vector3(0, 1, 0), wind_marker.rotation.y).rotated(Vector3(1, 0, 0), wind_marker.rotation.x)
	wind_direction *= -1.0
	
	if !debug_cloth:
		$Debug_Cloth.queue_free()

# By default, physics process is inactive.
# When the Glider enters the area, phys_process activates, and a force is put on the glider
# When the Glider leaves the area, phys_process deactivates, and the force no longer is applied
func _physics_process(delta: float) -> void:
	if player_glider == null:
		return
	player_glider.affect_by_wind(wind_direction * wind_force_magnitude)
	

func _on_body_entered(body: Node3D) -> void:
	if body is ElytraGlider:
		player_glider = body
		set_physics_process(true)


func _on_body_exited(body: Node3D) -> void:
	if body == player_glider:
		set_physics_process(false)
