extends RigidBody3D
class_name ElytraGlider2

## If checked off, the scene will be displayed through the attatched camera
@export var use_this_cam: bool = false
@export var rotation_torque: float = 400
#@export var angle_acceleration_curve: Curve
var forward_dir: Vector3
@export var forward_velocity: Vector3
@export var acceleration : float = 0.0
@export var minimum_speed : float = 50

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()

func _physics_process(delta: float) -> void:
	## Forward direction of travel
	#var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	#forward_dir = (global_transform.basis * forward_local_axis).normalized()
	#var delta_pitch = rotation.x * -1.0
	#var delta_yaw = rotation.y * -1.0
	#
	## Measuring Forward Velocity
	#forward_velocity = linear_velocity.project(forward_dir)
	#
	##Change the roll of the glider, and UPDATING forward direction
	handle_input()
	#forward_dir = (global_transform.basis * forward_local_axis).normalized()
	#delta_pitch += rotation.x
	#delta_yaw += rotation.y
	#print(delta_pitch)
	#print(delta_yaw)
	#
	## Determining Acceleration value based on pitch
	##dot > 0 means glider pointed down
	##dot < 0 means glider pointed up
	#acceleration = Vector3.UP.dot(forward_dir) * -10
	#var acceleration_vector = Vector3(forward_dir) * acceleration
	
	# Chaning the direction of linear velocity 
	#state.linear_velocity -= forward_velocity
	#var new_forward_velocity = Vector3(forward_dir) * forward_velocity.length()
	#new_forward_velocity += acceleration_vector
	#state.linear_velocity += new_forward_velocity
	#
	#state.apply_central_force(find_lift(new_forward_velocity))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Forward direction of travel
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	forward_dir = (global_transform.basis * forward_local_axis).normalized()
	var delta_pitch = rotation.x * -1.0
	var delta_yaw = rotation.y * -1.0
	
	# Measuring Forward Velocity
	forward_velocity = state.linear_velocity.project(forward_dir)
	
	#Change the roll of the glider, and UPDATING forward direction
	#handle_input(state)
	forward_dir = (global_transform.basis * forward_local_axis).normalized()
	
	
	# Determining Acceleration value based on pitch
	#dot > 0 means glider pointed down
	#dot < 0 means glider pointed up
	acceleration = Vector3.UP.dot(forward_dir) * -10
	var acceleration_vector = Vector3(forward_dir) * acceleration
	
	# Chaning the direction of linear velocity 
	state.linear_velocity -= forward_velocity
	var new_forward_velocity = Vector3(forward_dir) * forward_velocity.length()
	new_forward_velocity += acceleration_vector
	state.linear_velocity += new_forward_velocity
	
	state.apply_central_force(find_lift(new_forward_velocity))

func find_lift(forward_velocity: Vector3):
	var max_lift = 30.0;
	var up_dir = forward_velocity.normalized().rotated((global_transform.basis * Vector3(-1, 0, 0)).normalized(), deg_to_rad(90))
	var lift_force = min(forward_velocity.length() * 0.7, max_lift) 
	return up_dir * lift_force

func handle_input():
	# Player Input to handle glider direction
	if Input.is_action_pressed("bank_left"):
		apply_torque(Vector3(0, 1, 0) * rotation_torque)
	if Input.is_action_pressed("bank_right"):
		apply_torque(Vector3(0, -1, 0) * rotation_torque)
	
	# Player input to handle chaning pitch
	var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
	if Input.is_action_pressed("pitch_down"):
		apply_torque(left_vector * rotation_torque)
	if Input.is_action_pressed("pitch_up"):
		apply_torque(left_vector * rotation_torque * -1.0)
