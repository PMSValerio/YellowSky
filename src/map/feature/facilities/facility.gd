extends Feature


onready var tooltip = $Tooltip
onready var sprite = $PerspectiveSprite

# stats (might be modified by upgrades)
var production_rate = 5
var consumption_rate = 2
var capacity = 100 # max storage capacity

var health = 0
var energy = 100 # fuel to keep running
var stored = 0

var running = false

var _update_step = 0


func _process(delta: float) -> void:
	if _update_step >= Global.UPDATE_FREQ:
		_update_step = 0
		_tick()
	else:
		_update_step += delta


func _physics_process(_delta: float) -> void:
	# this is done so that the tooltip's scale isn't affected by perspective warping, only the position
	# still don't know what's better, add Tootip as child of Sprite instead to warp scale as well
	tooltip.position = sprite.position + Vector2(0, -64) * sprite.scale


# update facility stats
func _tick() -> void:
	if energy > 0:
		# consume energy per update
		energy -= consumption_rate
		if energy <= 0:
			energy = 0
			# alert facility power off
			print("Facility switching off")
			switch_facility(false)
		
		# update stored resource
		if stored < capacity:
			stored = min(capacity, stored + production_rate)
			if stored == capacity:
				print("Facility full")
				pass # alert facility full
	
	tooltip.update_items({"energy": energy, "stored":  stored})
	
	# TODO: remove
	tooltip.visible = true


func toggle_tooltip(toggle: bool) -> void:
	tooltip.visible = toggle


# function for turning facility on/off, changing visuals and other stuff
func switch_facility(on_off) -> void:
	running = on_off
	# TODO: graphics update, signals?
