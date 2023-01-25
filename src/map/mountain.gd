extends StaticBody2D
class_name Mountain


func set_discovered(discovered = true):
	$Sprite.frame_coords.x = 0 if discovered else 1
