extends Camera2D

var _rng = RandomNumberGenerator.new()
var shake_strength = 0
var default_offset = Vector2.ZERO

func _ready() -> void:
	_rng.randomize()

func _physics_process(_delta: float) -> void:
	if shake_strength > 0:
		offset = Vector2(_rng.randf_range(-1, 1) * shake_strength, _rng.randf_range(-1, 1) * shake_strength)

func set_shake(strength = 1):
	shake_strength = strength
	if strength == 0:
		offset = Vector2.ZERO
