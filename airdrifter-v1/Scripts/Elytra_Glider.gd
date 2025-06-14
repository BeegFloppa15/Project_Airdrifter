extends RigidBody3D

@export var use_this_cam: bool = false
@export var rotation_rate: float = 50;
@export var angle_acceleration_curve: Curve
@export var forward_velocity: Vector3
@export var acceleration : float = 0.0

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()

func _physics_process(delta: float) -> void:
	
	# Player Input to handle glider pitch and direction
	var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
	if Input.is_action_pressed("pitch_down"):
		rotate(left_vector, deg_to_rad(rotation_rate * delta))
	if Input.is_action_pressed("pitch_up"):
		rotate(left_vector, deg_to_rad(rotation_rate * delta * -1))
	if Input.is_action_pressed("bank_left"):
		rotate(Vector3.MODEL_TOP, deg_to_rad(rotation_rate * delta ))
	if Input.is_action_pressed("bank_right"):
		rotate(Vector3.MODEL_TOP, deg_to_rad(rotation_rate * delta * -1.0))
	
	# Forward direction of travel
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	var forward_dir: Vector3 = (global_transform.basis * forward_local_axis).normalized()
	
	# dot product between the forward direction and Vector3.UP: 
	#dot > 0 means glider pointed down
	#dot < 0 means glider pointed up
	acceleration += angle_acceleration_curve.sample(Vector3.UP.dot(forward_dir)) * 25
	if acceleration < 0:
		acceleration *= -1.0
	
	apply_central_force(forward_dir * acceleration)
	
	forward_velocity = linear_velocity.project(forward_dir)
