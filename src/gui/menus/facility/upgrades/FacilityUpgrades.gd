extends Control

var facility_entity : Facility = null # the actual facility node

# In the scene where you are calling the other scene
func _ready():
	var button1 = get_node("Button1")
	button1.connect("pressed", self, "on_button1_pressed")
	var button2 = get_node("Button2")
	button2.connect("pressed", self, "on_button2_pressed")
	var button3 = get_node("Button3")
	button3.connect("pressed", self, "on_button3_pressed")

func set_context(context):
	if context is Facility:
		facility_entity = context

func on_button1_pressed():
	print("Button1 pressed!")
	#Production Rate
	
	#Max Capacity
	
	#Durability
func on_button2_pressed():
	print("Button2 pressed!")
	#Production Rate
	
	#Max Capacity
	
	#Durability
func on_button3_pressed():
	print("Button3 pressed!")
	#Production Rate
	
	#Max Capacity
	
	#Durability



