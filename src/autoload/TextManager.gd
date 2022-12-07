extends Node
class_name TextManager

var _text_directories = {
	Global.Text.ITEMS: "res://assets/config_text/items/",
	Global.Text.FACILITIES: "res://assets/config_text/facilities/",
	Global.Text.SETTLEMENTS: "res://assets/config_text/settlements/",
	Global.Text.NPCS: "res://assets/config_text/npcs/",
}


func get_text_from_file(text_type, file_name, key_array):
	var file = File.new()
	var file_path = _text_directories[text_type] + file_name
	if file.file_exists(file_path):
		file.open(file_path, File.READ)
		var data = parse_json(file.get_as_text())
		
		for key in key_array:
			data = data[key]
		file.close()
		return data
	return {}
