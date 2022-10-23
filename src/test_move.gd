extends Node2D
var can_interact = false
var can_move = true
var is_moving = false
var is_moving_cache = false
var screen_size_pan_margins = 0
var screen_size =  Vector2.ZERO
var pan_margin_division_rate = 23
var pan_cam_speed = 5
var mouse_is_on_window = false
var init_cam_pos = 0
var tween_ref = null
var cam_ref = null
var mouse_pos = 0
var cam_move_direction = Vector2.ZERO
var player_speed = 64

func _ready():
	screen_size_pan_margins = Global.get_screen_size().x / pan_margin_division_rate
	screen_size = Global.get_screen_size()
	init_cam_pos = $Camera2D.position
	tween_ref = $Camera2D/Tween
	cam_ref = $Camera2D

func _physics_process(delta: float) -> void:
	if can_move == true:

		is_moving_cache = is_moving

		var forcex = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var forcey = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		position += Vector2(forcex, forcey) * delta * player_speed

		if forcex == 0 && forcey == 0:
			is_moving = false
		else:
			is_moving = true

		if is_moving_cache != is_moving && is_moving == true:
			started_moving()

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_is_on_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_is_on_window = true
		
func _process(_delta):

	mouse_pos = get_viewport().get_mouse_position()
	cam_move_direction = Vector2.ZERO
	
	if mouse_pos.x > screen_size.x - screen_size_pan_margins:
		cam_move_direction = Vector2(1, 0)
	elif mouse_pos.x < screen_size_pan_margins:
		cam_move_direction = Vector2(-1, 0)
	elif mouse_pos.y > screen_size.y - screen_size_pan_margins:
		cam_move_direction = Vector2(0, 1)
	elif mouse_pos.y < screen_size_pan_margins:
		cam_move_direction = Vector2(0, -1)
	else:
		cam_move_direction = Vector2.ZERO

	if mouse_is_on_window == true && UI.visible == false && is_moving == false:
		cam_ref.position += cam_move_direction * pan_cam_speed
		
	if Input.is_action_just_pressed("Interact") && can_interact == true:
		UI.visible = !UI.visible
		can_move = !can_move

func _reset_cam_pos():
	tween_ref.interpolate_property(cam_ref, "position", cam_ref.position, init_cam_pos, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_ref.start()
	#yield(tween_ref, "tween_all_completed")

func started_moving():
	if cam_ref.position != init_cam_pos:
		_reset_cam_pos()
		
	
func _on_Area2D_body_entered(body:Node):
	print("bodyentered:" + body.name)

func _on_World_tile_entered(id: int):

	print('entered')

	if id == 1:
		$Sprite/InteractPrompt.visible = true
		can_interact = true
	else:
		$Sprite/InteractPrompt.visible = false
		can_interact = false
