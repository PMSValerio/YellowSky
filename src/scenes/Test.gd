extends Control


var sub_active = false


func _on_Main1_pressed() -> void:
	if not sub_active:
		sub_active = true
		$Sub.visible = true
		$Sub.mouse_filter = Control.MOUSE_FILTER_STOP
		$Main.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_Main2_pressed() -> void:
	print("Main 2 pressed")


func _on_Button_pressed() -> void:
	if sub_active:
		sub_active = false
		$Sub.visible = false
		$Sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Main.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		print("Sub pressed")
