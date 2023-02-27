# This class scans the scene to and connects signals from UI elements to audio stream playrs it creates
# This is easy and efficient, unlike replacing every UI element and creating dozens of AudioStreamPlayer nodes

extends Node

export var root_path : NodePath

# create audio player instances
onready var sounds = {
	"UI_Click" : AudioStreamPlayer.new(),
	'UI_TabChanged' : AudioStreamPlayer.new(),
	}

func ui_sfx_play(sound : String) -> void:
#	printt("Playing sound:", sound)
	sounds[sound].play()

func ui_tab_sfx_play(_tab, sound : String) -> void:
#	printt("Playing sound:", sound)
	sounds[sound].play()

func _ready() -> void:
	assert(root_path != null, "Empty root path for UI Sounds!")

	# set up audio stream players and load sound files
	for i in sounds.keys():
		sounds[i].stream = load("res://assets/sfx/ui/" + str(i) + ".wav")
		# assign output mixer bus
		sounds[i].bus = "UI"
		# add them to the scene tree
		add_child(sounds[i])

	# connect signals to the method that plays the sounds
	install_sounds(get_node(root_path))


func install_sounds(node: Node) -> void:
	for i in node.get_children():
		if (i is Button or i is TextureButton) and i.disabled == false:
			i.connect("pressed", self, 'ui_sfx_play', ["UI_Click"])
		elif i is TabContainer:
			i.connect("tab_changed", self, 'ui_tab_sfx_play', ["UI_TabChanged"])
		# recursion
		install_sounds(i)
