extends RigidBody3D
class_name ElytraGlider

@export var use_this_cam: bool = false
@export var rotation_rate: float = 50
@export var rotation_torque: float = 400
@export var angle_acceleration_curve: Curve
@export var forward_velocity: Vector3
@export var acceleration : float = 0.0
@export var minimum_speed : float = 50
var actual_min_speed : float
var areas_in = 0

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()
	
	actual_min_speed = minimum_speed

func _physics_process(delta: float) -> void:
	
	# Player Input to handle glider pitch and direction
	if Input.is_action_pressed("bank_left"):
		apply_torque(Vector3(0, 1, 0) * rotation_torque)
	if Input.is_action_pressed("bank_right"):
		apply_torque(Vector3(0, -1, 0) * rotation_torque)
	
	var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
	if Input.is_action_pressed("pitch_down"):
		#rotate(left_vector, deg_to_rad(rotation_rate * delta))
		apply_torque(left_vector * rotation_torque)
	if Input.is_action_pressed("pitch_up"):
		#rotate(left_vector, deg_to_rad(rotation_rate * delta * -1))
		apply_torque(left_vector * rotation_torque * -1.0)
	
	# Forward direction of travel
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	var forward_dir: Vector3 = (global_transform.basis * forward_local_axis).normalized()
	
	# dot product between the forward direction and Vector3.UP: 
	#dot > 0 means glider pointed down
	#dot < 0 means glider pointed up
	if areas_in == 0:
		acceleration += angle_acceleration_curve.sample(Vector3.UP.dot(forward_dir))  * 25
		if acceleration < 0:
			acceleration = 0
	
	# If acceleration is lower than some minimum speed, push the plane HORIZONTALLY forward by the min speed
	if acceleration < minimum_speed and forward_velocity.length() < minimum_speed:
		var bruh_vector = Vector3(forward_dir)
		bruh_vector.y = 0
		apply_central_force(bruh_vector * actual_min_speed)
	# Otherwise, just push the plane forward horz and vert
	else:
		apply_central_force(forward_dir * acceleration)
	
	forward_velocity = linear_velocity.project(forward_dir)
	apply_central_force(find_lift(forward_velocity))
	
	#Clamping values to stop unwanted rotational behavior (my silly billy ahh ahh keeps forgetting
	# to do deg_to_rad
	rotation = rotation.clamp(Vector3(deg_to_rad(-85.0), -10, 0.0), Vector3(deg_to_rad(85.0), 10, 0.0))

func change_areas_in(change: int):
	areas_in += change

func find_lift(forward_velocity: Vector3):
	var max_lift = 30.0;
	var up_dir = forward_velocity.normalized().rotated((global_transform.basis * Vector3(-1, 0, 0)).normalized(), deg_to_rad(90))
	var lift_force = min(forward_velocity.length() * 0.7, max_lift) 
	return up_dir * lift_force

func affect_by_wind(wind_vector: Vector3):
	# A unit vector of the direction the glider is pointed in
	var forward_dir = forward_velocity.normalized()
	# The projection of wind onto forward direction will increase or decrease acceleration
	if forward_dir.dot(wind_vector) > 0:
		acceleration += (wind_vector.project(forward_dir).length() / (mass * 5))
	else:
		acceleration -= (wind_vector.project(forward_dir).length() / (mass * 5))
	# Apply all the other components of the wind vector as a normal force
	apply_central_force(wind_vector.slide(forward_dir))
	
	
func remove_min_speed():
	actual_min_speed = 0

func reset_min_speed():
	actual_min_speed = minimum_speed
