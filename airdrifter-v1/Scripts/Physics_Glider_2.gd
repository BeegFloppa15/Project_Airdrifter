extends RigidBody3D

@export var liftForce: float = 0.5
@export var use_this_cam: bool = false
@export var rotation_rate: float = 50;
@export var forward_velocity: Vector3

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
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Forward direction of travel
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	var forward_dir: Vector3 = (global_transform.basis * forward_local_axis).normalized()
	
	#The component of the linear velocity that is IN THE FORWARD DIRECTION
	forward_velocity = linear_velocity.project(forward_dir)
	
	# Using Forward Velocity to apply lift
	state.apply_central_force(Vector3(0, find_lift(forward_velocity), 0))
	
	# Trading altitude for speed strategy:
		# Take Y component of linear_velocity
	var vertical_velo = state.linear_velocity.y
		# (If Y comp is negative?) Multiply by some constant to get a float
	if vertical_velo < 0:
		var add_speed = 0.5 * pow(vertical_velo,2 ) * 3
		# apply this float force in the direction of forward dir as a force, with NO y component
		var horz_direction = forward_dir * add_speed
		horz_direction.y = 0
		state.apply_central_force(forward_dir * add_speed)

#Lift Strategy: given the forward velocity of the direction we are traveling
func find_lift(velocity: Vector3):
	
	# Calculate lift using forward velocity (REALISTIC: 0.5 * velocity^2 * constant)
	var lift = 0.5 * pow(velocity.length(), 2) * liftForce
	# Find the UNIT VECTOR of the LOCAL UP DIRECTION
	var up_local_axis: Vector3 = Vector3(0, 1, 0)
	var up_dir: Vector3 = (global_transform.basis * up_local_axis).normalized()
	# Multiply lift by up unit vector 
	var lift_force: Vector3 = up_dir * lift
	# Return JUST the Y component
	return lift_force.y
