extends KinematicBody2D


signal interact(position)

const SPEED := 64.0
const PAN_MARGIN_DIVISION_RATE = 10
const PAN_CAM_SPEED = 5

onready var _cam = $Camera2D
onready var _cam_tween = $Camera2D/Tween
onready var _prompt = $Sprite/Node2D/InteractPrompt

onready var screen_size_pan_margins = Global.get_screen_size().x / PAN_MARGIN_DIVISION_RATE
onready var screen_size = Global.get_screen_size()
onready var init_cam_pos = _cam.position

var is_moving = false
var is_moving_cache = false

var mouse_is_on_window = false


func _ready() -> void:
	Global.set_cam(_cam)


func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_is_on_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_is_on_window = true


func _physics_process(_delta: float) -> void:
	var direction = Vector2(
		Input.get_action_strength("mov_right") - Input.get_action_strength("mov_left"),
		Input.get_action_strength("mov_down") - Input.get_action_strength("mov_up")
	).normalized()
	var _v = move_and_slide(SPEED * direction)
	
	is_moving_cache = is_moving
	is_moving = not direction.is_equal_approx(Vector2.ZERO)
	
	_update_cam()
	
	if is_moving and not is_moving_cache and _cam.position != init_cam_pos:
		_reset_cam_pos()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		emit_signal("interact")


func _update_cam():
	var mouse_pos = get_viewport().get_mouse_position()
	var cam_move_direction = Vector2.ZERO
	
	cam_move_direction = Vector2.ZERO
	if mouse_pos.x > screen_size.x - screen_size_pan_margins:
		cam_move_direction.x += 1
	if mouse_pos.x < screen_size_pan_margins:
		cam_move_direction.x -= 1
	if mouse_pos.y > screen_size.y - screen_size_pan_margins:
		cam_move_direction.y += 1
	if mouse_pos.y < screen_size_pan_margins:
		cam_move_direction.y -= 1
	
	if mouse_is_on_window && not is_moving:
		_cam.position += cam_move_direction.normalized() * PAN_CAM_SPEED


func _reset_cam_pos():
	_cam_tween.interpolate_property(_cam, "position", _cam.position, init_cam_pos, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_cam_tween.start()


func _on_World_tile_entered(id: int):
	
	if id == 1:
		_prompt.visible = true
		#can_interact = true
	else:
		_prompt.visible = false
		#can_interact = false
