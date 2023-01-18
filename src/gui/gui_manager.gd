extends CanvasLayer


# preloaded menu scenes
var _menus = {
	Global.Menus.TEST: preload("res://src/gui/menus/TestUI.tscn"),
	Global.Menus.PAUSE_SCREEN: preload("res://src/gui/menus/pause/PauseScreen.tscn"),
	Global.Menus.FACILITY_MENU: preload("res://src/gui/menus/facility/FacilityMenu.tscn"),
	Global.Menus.MAIN_MENU: preload("res://src/gui/menus/main/MainMenu.tscn"),
	Global.Menus.SETTLEMENT_SCREEN: preload("res://src/gui/menus/settlement_screen/SettlementScreen.tscn")
}

# the stack of loaded menus, when empty, game should process normally
var menu_stack = []


func _ready() -> void:
	var _v = EventManager.connect("push_menu", self, "_on_push_menu")
	_v = EventManager.connect("pop_menu", self, "_on_pop_menu")


func get_current_menu():
	return menu_stack.back() if menu_stack.size() > 0 else null


func _get_menu_scene(menu):
	return _menus[menu].instance()


func _on_push_menu(menu, context):
	if menu in _menus and (menu_stack.empty() or menu_stack.back() != menu):
		var new_menu = _get_menu_scene(menu)
		menu_stack.push_back(menu)
		
		# TODO: refactor if menus down the stack are still visible, even if inactive
		for child in get_children():
			child.queue_free()
		if new_menu.has_method("set_context"): # if menu has a function to accept context, call it
			new_menu.set_context(context)
		call_deferred("add_child", new_menu)
		# ----------
		
		if not get_tree().paused:
			# TODO: pausing could be handled by the menu
			get_tree().paused = true
	else:
		print("Menu not found")


func _on_pop_menu():
	if not menu_stack.empty():
		var _popped = menu_stack.pop_back()
		for child in get_children():
			child.queue_free()
		# TODO: properly process popped menu
		
		if menu_stack.empty():
			# TODO: pausing could be handled by the menu
			get_tree().paused = false
		else:
			var new_menu = _get_menu_scene(menu_stack.back())
			
			call_deferred("add_child", new_menu)
