extends KinematicBody2D

signal interact(position)
signal health_changed(health_val)
signal stamina_changed(stamina_val)

const SPEED := 96.0
const PAN_MARGIN_DIVISION_RATE = 10
const PAN_CAM_SPEED = 5
const TOTAL_HEALTH = 100
const TOTAL_STAMINA = 100
const HEALTH_LOSS_RATE = 1
const MOVE_STAMINA_THRESHOLD = 1 # average values can be between 0.1 - 5.0
const STAMINA_LOSS_RATE = 10

onready var _cam_anchor = $CameraAnchor
onready var _cam = $CameraAnchor/Camera2D
onready var _cam_tween = $CameraAnchor/Tween
onready var _prompt_anchor = $Node2D
onready var _prompt = $Node2D/InteractPrompt

onready var sprite = $Sprite
onready var anim = $AnimationPlayer

onready var screen_size_pan_margins = Global.get_screen_size().x / PAN_MARGIN_DIVISION_RATE
onready var screen_size = Global.get_screen_size()
onready var init_cam_pos = _cam_anchor.position

var direction = Vector2.DOWN # direction player is facing

var is_moving = false
var is_moving_cache = false
var total_walked_distance = 0
var walked_distance_step = 0

var mouse_is_on_window = false

var current_health = TOTAL_HEALTH setget set_health
var current_stamina = TOTAL_STAMINA setget set_stamina
var is_alive = true
var out_of_stamina = false
var out_of_stamina_timer = Timer.new()

func _ready() -> void:
	Global.set_cam(_cam)
	Global.set_player(self)

	# set out_of_stamina_timer 
	out_of_stamina_timer.connect("timeout", self, "change_health", [-HEALTH_LOSS_RATE])
	out_of_stamina_timer.wait_time = 0.2
	out_of_stamina_timer.one_shot = false
	add_child(out_of_stamina_timer)

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_is_on_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_is_on_window = true

func _physics_process(_delta: float) -> void:
	# so that the prompt isn't affected by the scale warping, but only by the position warping
	_prompt_anchor.global_position = sprite.global_position
	
	var move_direction = Vector2(
		Input.get_action_strength("mov_right") - Input.get_action_strength("mov_left"),
		Input.get_action_strength("mov_down") - Input.get_action_strength("mov_up")
	).normalized()
	var _v = move_and_slide(SPEED * move_direction)
	if move_direction.length() != 0: # only update direction if moving
		direction = move_direction
	
	is_moving_cache = is_moving
	is_moving = not move_direction.is_equal_approx(Vector2.ZERO)
	
	_update_visuals()
	
	_update_cam()

	if is_moving and not is_moving_cache and _cam_anchor.position != init_cam_pos:
		_reset_cam_pos()

	# decrease stamina in discrete steps
	if is_moving:
		total_walked_distance += _delta
		walked_distance_step += _delta

		if walked_distance_step >= MOVE_STAMINA_THRESHOLD:
			walked_distance_step = 0
			change_stamina(-STAMINA_LOSS_RATE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		emit_signal("interact", global_position)
	if event.is_action_pressed("ctrl_main_menu"):
		EventManager.emit_signal("push_menu", Global.Menus.INVENTORY_SCREEN, null)

# CUSTOM FUNCTIONS::::::::::::::::::::::::::::::::::::::::::::
# stats
func set_health(new_val):
	current_health = new_val
	current_health = clamp(current_health, 0, TOTAL_HEALTH)
	emit_signal("health_changed", current_health)

	if current_health <= 0:
		die()

func set_stamina(new_val):
	current_stamina = new_val
	current_stamina = clamp(current_stamina, 0, TOTAL_STAMINA)
	emit_signal("stamina_changed", current_stamina)

	if current_stamina <= 0:
		out_of_stamina = true
		out_of_stamina_timer.start()
	else:
		out_of_stamina = false
		out_of_stamina_timer.stop()
	
func change_health(change_value):
	set_health(current_health + change_value)
	
func change_stamina(change_value):
	set_stamina(current_stamina + change_value)

func die():
	if is_alive:
		is_alive = false
		print("You Died!")


# TODO: move to state machine
# update animation
func _update_visuals():
	var movement = "run" if is_moving else "idle"
	var dir = "front"
	# TODO: possibly include 45º animations
	if direction.y > 0:
		dir = "front"
	elif direction.y < 0:
		dir = "back"
	elif direction.x > 0:
		dir = "right"
	elif direction.x < 0:
		dir = "left"
	
	var animation = movement + "_" + dir
	if animation != anim.current_animation:
		anim.play(animation)


# cam funcs
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
		_cam_anchor.position += cam_move_direction.normalized() * PAN_CAM_SPEED

func _reset_cam_pos():
	_cam_tween.interpolate_property(_cam_anchor, "position", _cam_anchor.position, init_cam_pos, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_cam_tween.start()

# others
func _on_World_tile_entered(interactable):
	_prompt.visible = interactable
