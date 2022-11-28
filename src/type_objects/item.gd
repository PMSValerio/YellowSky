extends Reference
class_name Item

var id
var type
var texture
var value
var stat

var usable


func init(_id : int, _type: int, _texture, _value : float, _stat : float, _usable : bool):
	id = _id
	type = _type
	texture = _texture
	value = _value
	stat = _stat
	usable = _usable
