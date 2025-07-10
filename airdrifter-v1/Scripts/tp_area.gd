## This is for debugging purposes: when the glider enters, it telleports back up to a set Y value
extends Area3D

@export var height_marker: Marker3D

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.position.y = height_marker.position.y
