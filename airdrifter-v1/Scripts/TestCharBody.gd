extends CharacterBody3D

var rotation_rate = 0.0
var max_rotation_rate = 30.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("bank_left"):
		rotation_rate = lerpf(rotation_rate, max_rotation_rate, 0.1)
	if Input.is_action_pressed("bank_right"):
		rotation_rate = lerpf(rotation_rate, max_rotation_rate * -1.0, 0.1)
	rotate(Vector3.UP, rotation_rate *delta)
