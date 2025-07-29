extends Control

@export var air_controls_img: Texture
@export var ground_controls_img: Texture
var paused: bool


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_game()

func _on_controls_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$ControlsImg.texture = ground_controls_img
	else:
		$ControlsImg.texture = air_controls_img


func pause_game():
	self.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	paused = true


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if not paused:
			pause_game()
		else:
			resume_game()


func resume_game() -> void:
	self.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	paused = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
