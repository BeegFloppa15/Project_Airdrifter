extends CharacterBody3D

@export var rotation_rate: float = 50.0

func _physics_process(delta: float) -> void:
	translate(Vector3(0, 0, 10 * delta))

func _process(delta: float) -> void:
	var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
	
	if Input.is_action_pressed("pitch_down"):
		rotate(left_vector, deg_to_rad(rotation_rate * delta))
	if Input.is_action_pressed("pitch_up"):
		rotate(left_vector, deg_to_rad(rotation_rate * delta * -1))
	if Input.is_action_pressed("bank_left"):
		rotate(Vector3.MODEL_TOP, deg_to_rad(rotation_rate * delta ))
	if Input.is_action_pressed("bank_right"):
		rotate(Vector3.MODEL_TOP, deg_to_rad(rotation_rate * delta * -1.0))
	
