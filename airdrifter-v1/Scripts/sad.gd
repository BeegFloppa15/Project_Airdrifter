extends RigidBody3D

func _process(delta: float) -> void:
	translate(Vector3(0, 0, 10 * delta))
