extends Disaster


var candidates = []


func _ready() -> void:
	back.connect("anim_end", self, "_on_back_anim_end")
	
	var facilities = get_tree().get_nodes_in_group("facilities")
	for fac in facilities:
		if fac.is_discovered():
			candidates.append(fac)
	var settlements = get_tree().get_nodes_in_group("settlements")
	for set in settlements:
		if set.is_discovered():
			candidates.append(set)


func start():
	back.start()


func end():
	back.end()


func _on_back_anim_end(_start):
	if _start:
		$AnimationPlayer.play("play")
	else:
		back.queue_free()
		back = null
		emit_signal("disaster_end")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	back.end()


func lightning():
	var amount = randi() % 5 + 1
	
	for _i in range(amount):
		if candidates.size() > 0:
			var rix = randi() % candidates.size()
			var target = candidates[rix]
			candidates.remove(rix)
			target.blackout()
