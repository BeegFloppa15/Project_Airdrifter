extends Control

@export var glider_object : ElytraGlider2

func _ready():
	if StartStatus.menu_opened_once:
		show()
	else:
		hide()

func _process(delta: float) -> void:
	$AltitudeLabel.set_text("Altitude: %0.2f" %glider_object.position.y)
	$"Velocity Label".set_text("Velocity: %0.2f" %glider_object.linear_velocity.length())
	$"AoA Label".set_text("%0.2f : Pitch" %glider_object.rotation_degrees.x)
	$AirspeedLabel.set_text("Forward Airspeed: %0.2f" %glider_object.forward_velocity.length())
	$AccelLabel.set_text("%0.2f : Acceleration" %glider_object.acceleration)
	var status_text: String
	if glider_object.current_state == 0:
		status_text = "Flying"
	elif glider_object.current_state == 1:
		status_text = "Rolling"
	else:
		status_text = "Grounded"
	$StatusLabel.set_text(status_text)


func _on_welcome_ui_game_started() -> void:
	show()
