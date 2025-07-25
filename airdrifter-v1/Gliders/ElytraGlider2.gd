extends RigidBody3D
class_name ElytraGlider2

## If checked off, the scene will be displayed through the attatched camera
@export var use_this_cam: bool = false
## Higher Torque will result in the glider pitching and tunring faster
@export var rotation_torque: float = 200
var forward_dir: Vector3
var old_forward_velo: Vector3
@export var forward_velocity: Vector3
@export var acceleration : float = 0.0

## The minimum length of forward velocity for the glider to be able to take off
@export var stall_speed : float = 65.0

var min_pitch : float = -70.0
var max_pitch : float = 70.0

## A type that will change the behavior of the glider, and its controls[br]
## [b]NOTE[/b]: This is [u]DEFINITELY not the best way to implement this feature[/u]: all possible functionality in this one class, and changing what we do 
## with an if else statement. For future development, the strategy pattern or a state machine would be better, but I think that would entail refactoring a lot of code
enum glider_state {
	## Glider is not in contact with the ground or any other terrain
	FLYING,
	## Glider is in contact with the ground, forward velocity is FASTER than the stall speed needed to take off
	ROLLING,
	## Glider is in contact with the ground, forward velocity is not fast enough to take off
	GROUNDED
}
@export var current_state: glider_state

func _ready() -> void:
	if use_this_cam:
		$"CamRoot/Horz/Vert/3rdPerCamera".make_current()
	else:
		$"CamRoot/Horz/Vert/3rdPerCamera".queue_free()
	
	old_forward_velo = Vector3.ZERO
	
	# if we are not contacting anything, the glider is flying
	if get_contact_count() == 0:
		current_state = glider_state.FLYING
	else:
		current_state = glider_state.GROUNDED

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	state.linear_velocity -= old_forward_velo
	
	# Pitch and rotate glider
	handle_input()
	
	# Finding forward DIRECTION (unit Vector)
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	forward_dir = (global_transform.basis * forward_local_axis).normalized()
	
	if current_state == glider_state.FLYING:
		# dot product between the forward direction and Vector3.UP: 
		#dot > 0 means glider pointed down
		#dot < 0 means glider pointed up
		acceleration = Vector3.UP.dot(forward_dir) * -2
	else:
		acceleration = 0
		if Input.is_key_pressed(KEY_SHIFT):
			physics_material_override.friction = 0.75
		else:
			physics_material_override.friction = 0.1
	
	forward_velocity = forward_dir * (old_forward_velo.length() + acceleration)
	
	state.linear_velocity += forward_velocity
	
	state.apply_central_force(find_lift(forward_velocity))
	
	#NOTE: this method was ment to solve the issue of the glider not losing altitude when it was pitched straight up
	# However it's not really working and producing unexpected behaviors.
	# calculate_stall(forward_velocity)
	
	old_forward_velo = state.linear_velocity.project(forward_dir)
	
	# Changing the glider's state depending on if we contact the ground, and our forward speed
	if state.get_contact_count() == 0:
		current_state = glider_state.FLYING
	else:
		for i in state.get_contact_count():
			var contact_collider = state.get_contact_collider_object(i)
			##TODO Use state.get_contact_collider_position(i)
			
			if contact_collider.get_collision_layer() == 4:
				if forward_velocity.length() > stall_speed:
					current_state = glider_state.ROLLING
				else:
					current_state = glider_state.GROUNDED
				break
				

func _physics_process(delta: float) -> void:
	#Clamping values to stop unwanted rotational behavior 
	rotation_degrees = rotation_degrees.clamp(Vector3(min_pitch, -360.0, 0.0), Vector3(max_pitch, 360.0, 0.0))
	

## Input: a vector3 that represents the glider's forward velocity.
## If the forward velocity is slower than some stall threshold, force the glider to pitch down
## @deprecated : this method sucks
func calculate_stall(forward_velocity: Vector3):
	var stall_speed = 10
	if forward_velocity.length() < stall_speed:
		var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
		apply_torque(left_vector * ((rotation_torque/10) * stall_speed-forward_velocity.length()))

func find_lift(forward_velocity: Vector3):
	var max_lift = mass * 9.8;
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
	
	if current_state == glider_state.FLYING:
		# Player input to handle chaning pitch
		var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
		if Input.is_action_pressed("pitch_down"):
			apply_torque(left_vector * rotation_torque)
		if Input.is_action_pressed("pitch_up"):
			apply_torque(left_vector * rotation_torque * -1.0)

	elif current_state == glider_state.ROLLING:
		if Input.is_action_pressed("pitch_up"):
			var left_vector = (global_transform.basis * Vector3.MODEL_LEFT).normalized()
			apply_torque(left_vector * rotation_torque * -1.0)
	
	else:
		if Input.is_action_pressed("pitch_down"):
			var push_force = 50.0
			apply_central_force(forward_dir * push_force)


func _on_body_entered(body: Node) -> void:
	print("hit something")
	if body.get_collision_layer() == 4:
		min_pitch = 0.0
		print("Forcing Level")
		await get_tree().create_timer(1.0).timeout
		min_pitch = -70.0
		print("level free")
		
