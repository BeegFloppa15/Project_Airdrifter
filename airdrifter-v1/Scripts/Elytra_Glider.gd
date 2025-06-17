extends RigidBody3D

@export var use_this_cam: bool = false
@export var rotation_rate: float = 50;
@export var angle_acceleration_curve: Curve
@export var forward_velocity: Vector3
@export var acceleration : float = 0.0
@export var minimum_speed : float = 50

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
	acceleration += angle_acceleration_curve.sample(Vector3.UP.dot(forward_dir))  * 25
	if acceleration < 0:
		acceleration *= -1.0
	
	# If acceleration is lower than some minimum speed, push the plane HORIZONTALLY forward by the min speed
	if acceleration < minimum_speed:
		var bruh_vector = forward_dir
		bruh_vector.y = 0
		apply_central_force(bruh_vector * minimum_speed * 4)
	# Otherwise, just push the plane forward horz and vert
	else:
		apply_central_force(forward_dir * acceleration)
	
	forward_velocity = linear_velocity.project(forward_dir)
	apply_central_force(find_lift(forward_velocity))

func find_lift(forward_velocity: Vector3):
	var max_lift = 50.0;
	var up_dir = forward_velocity.normalized().rotated((global_transform.basis * Vector3(-1, 0, 0)).normalized(), deg_to_rad(90))
	var lift_force = min(forward_velocity.length() * 0.7, max_lift) 
	return up_dir * lift_force
	
