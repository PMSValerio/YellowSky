extends Node

# TODO: When several jsons exist with diffferent data, they need to be set in here.
# For the time being, there is only 1 json file.
var _text_file_paths = {
	Global.Text.ITEMS: "res://src/gui/dialogue_repo.json",
	Global.Text.FACILITIES: "res://src/gui/dialogue_repo.json",
	Global.Text.SETTLEMENTS: "res://src/gui/dialogue_repo.json",
	Global.Text.NPCS: "res://src/gui/dialogue_repo.json"
} 

var _text_files = {
	Global.Text.ITEMS: "",
	Global.Text.FACILITIES: "" ,
	Global.Text.SETTLEMENTS: "",
	Global.Text.NPCS:  ""
}


func _ready():

	# Populate _text_files by parsing all json files, so that the data is always ready to access
	for text_type in Global.Text:
		_text_files[Global.Text[text_type]] = _load_text_files(_text_file_paths[Global.Text[text_type]])

	var temp_key_array = ["settlement1", "NPC", "Name"]
	print(get_text(Global.Text.ITEMS, temp_key_array))


func _load_text_files(file_path):
	var temp_file = File.new()
	if temp_file.file_exists(file_path):
		temp_file.open(file_path, File.READ)
		return parse_json(temp_file.get_as_text())


# Receives Global enum, and array of strings 
func get_text(text_type, key_array):

	var temp_text = _text_files[text_type]

	for i in range(0, key_array.size()):
		temp_text =  temp_text[key_array[i]]
		
	return temp_text