extends Control

@export var glider_object : RigidBody3D

func _process(delta: float) -> void:
	$AltitudeLabel.set_text("Altitude: %0.2f" %glider_object.position.y)
	$"Velocity Label".set_text("Velocity: %0.2f" %glider_object.linear_velocity.length())
	$"AoA Label".set_text("%0.2f : Pitch" %glider_object.rotation_degrees.x)
	$AirspeedLabel.set_text("Forward Airspeed: %0.2f" %glider_object.forward_velocity.length())
