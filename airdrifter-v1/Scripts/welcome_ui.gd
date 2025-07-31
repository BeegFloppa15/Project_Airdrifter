extends Control

@export var air_controls_img: Texture
@export var ground_controls_img: Texture

signal game_started

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if StartStatus.menu_opened_once:
		hide()
	else:
		show()
		get_tree().paused = true

func _on_controls_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$ControlsImg.texture = ground_controls_img
	else:
		$ControlsImg.texture = air_controls_img

func perma_hide():
	hide()
	StartStatus.menu_opened_once = true


func _on_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	perma_hide()
	game_started.emit()
