extends RigidBody3D

@export var liftForce: float
@export var use_this_cam: bool = false
@export var rotation_rate: float = 50;
@export var forward_vector: Vector3

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	# Current Velocity: Linear Velocity has the aspects of Initial Speed and direction, Lift, and Gravity 
	var current_velo = state.linear_velocity
	
	# Unit vector of where the glider is going
	forward_vector = (global_transform.basis * Vector3(0, 0, 1)).normalized()
	
	var new_velo : Vector3
	
	#Changing the direction of the current velocity to go where the glider is pointing
	new_velo = forward_vector * current_velo.length()
	state.apply_central_force(implement_lift(new_velo))
	
	#TODO: Implement drag to prevent the glider from accelerating out of control
	#TODO: Implement lift 
	
	#state.linear_velocity = new_velo
	
	# Adding Lift (effected by horizontal velocity)
	#state.linear_velocity.y += calculate_lift(state).y
	#
	#var vertical_velocity = linear_velocity.y
	#
	##Problem: When we rotate left and right, the plane doesn't turn immediately. That only changes as a result of losing altitude
	##if vertical_velocity < 0:
	#forward_vector = (global_transform.basis * Vector3(0, 0, 1)).normalized()
	#forward_vector *= vertical_velocity * -0.1
	#forward_vector.clamp(Vector3(-INF, 0, -INF), Vector3.INF)
	#state.linear_velocity += forward_vector
		

func implement_lift(velocity: Vector3) -> Vector3:
	# Finding Local Up Direction
	var up_vector = (global_transform.basis * Vector3(0, 1, 0)).normalized()
	up_vector *= velocity.length()
	return up_vector
	

func calculate_lift(state: PhysicsDirectBodyState3D) -> Vector3:
	# Finding Local Up Direction
	var up_vector = (global_transform.basis * Vector3(0, 1, 0)).normalized()
	# Finding Horizontal (X and Z) components of linear velocity
	var horizontal_velocity = state.linear_velocity
	#horizontal_velocity.y = 0.0
	
	# Calculating lift based on horizontal velocity
	var lift = up_vector *  horizontal_velocity.length() * 0.01
	return lift.clampf(0, state.linear_velocity.y * -1.0)

#Handling player input and rotation here for now
func _physics_process(delta: float) -> void:
	var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
	
	if Input.is_action_pressed("pitch_down"):
		rotate(left_vector, deg_to_rad(rotation_rate * delta))
	if Input.is_action_pressed("pitch_up"):
		rotate(left_vector, deg_to_rad(rotation_rate * delta * -1))
	if Input.is_action_pressed("bank_left"):
		rotate(Vector3.MODEL_TOP, deg_to_rad(rotation_rate * delta ))
	if Input.is_action_pressed("bank_right"):
		rotate(Vector3.MODEL_TOP, deg_to_rad(rotation_rate * delta * -1.0))
	
	#translate(Vector3(0, 0, 10 * delta))
