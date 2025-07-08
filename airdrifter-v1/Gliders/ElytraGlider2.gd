extends RigidBody3D
class_name ElytraGlider2

## If checked off, the scene will be displayed through the attatched camera
@export var use_this_cam: bool = false
@export var rotation_torque: float = 200
#@export var angle_acceleration_curve: Curve
var forward_dir: Vector3
var old_forward_velo: Vector3
@export var forward_velocity: Vector3
@export var acceleration : float = 0.0
@export var minimum_speed : float = 50

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()
	
	old_forward_velo = Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	state.linear_velocity -= old_forward_velo
	
	# Pitch and rotate glider
	handle_input()
	
	# Finding forward DIRECTION (unit Vector)
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	forward_dir = (global_transform.basis * forward_local_axis).normalized()
	
	# dot product between the forward direction and Vector3.UP: 
	#dot > 0 means glider pointed down
	#dot < 0 means glider pointed up
	acceleration = Vector3.UP.dot(forward_dir) * -2
	
	forward_velocity = forward_dir * (old_forward_velo.length() + acceleration)
	
	state.linear_velocity += forward_velocity
	
	state.apply_central_force(find_lift(forward_velocity))
	
	old_forward_velo = state.linear_velocity.project(forward_dir)

func _physics_process(delta: float) -> void:
	#Clamping values to stop unwanted rotational behavior (my silly billy ahh ahh keeps forgetting
	# to do deg_to_rad
	rotation = rotation.clamp(Vector3(deg_to_rad(-85.0), -10, 0.0), Vector3(deg_to_rad(85.0), 10, 0.0))

func find_lift(forward_velocity: Vector3):
	var max_lift = 30.0;
	var up_dir = forward_velocity.normalized().rotated((global_transform.basis * Vector3(-1, 0, 0)).normalized(), deg_to_rad(90))
	#up_dir.x = 0
	#up_dir.z = 0
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
