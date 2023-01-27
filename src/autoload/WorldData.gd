extends Node


var time_played = 0 # elapsed play time in seconds
var quest_log : QuestLog
var completed_quest_counter = 0
var failed_quest_counter = 0
var unlocked_facilities = [] # list of facility ids the player can build

var world_hope = 0 # corresponds to the cumulative amount of earned hope points


func _ready() -> void:
	quest_log = QuestLog.new()
	
	# TODO: if tutorial is enabled, unlock only energy facility
	unlocked_facilities.append_array([Global.FacilityTypes.COAL_PLANT, Global.FacilityTypes.PARTS_WORKSHOP, Global.FacilityTypes.WATER_PUMP, Global.FacilityTypes.CANNERY])
	unlocked_facilities.append_array([Global.FacilityTypes.WIND_FARM, Global.FacilityTypes.RECYCLER, Global.FacilityTypes.PURIFIER, Global.FacilityTypes.HYDROPONICS])
	
	var _v = EventManager.connect("hope_gained", self, "_on_hope_gained")


func _physics_process(delta: float) -> void:
	time_played += delta


func _on_hope_gained(amount):
	world_hope += amount


func unlock_facility(facility_id):
	if facility_id in Global.FacilityTypes.values() and not facility_id in unlocked_facilities:
		unlocked_facilities.append(facility_id)
