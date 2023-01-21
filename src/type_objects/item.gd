extends Reference
class_name Item

var id
var type
var subtype # this will probably only be used for compact resource items
var texture
var value
var stat
var usable

var name
var flavour_text


func init(_id, _type: int, _texture_path, _value : float, _stat : float, _usable : bool):
	id = _id
	type = _type
	texture = load(_texture_path)
	value = _value
	stat = _stat
	usable = _usable


func init_flavour(_name : String, _flavour_text : String):
	name = _name
	flavour_text = _flavour_text
