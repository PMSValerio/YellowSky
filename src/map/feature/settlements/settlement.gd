extends Feature
class_name Settlement


var inventory : Inventory = null 


func _ready():
	inventory = Inventory.new()
	inventory.init(2)


func interact() -> void :
	EventManager.emit_signal("push_menu", Global.Menus.SETTLEMENT_SCREEN, self)
