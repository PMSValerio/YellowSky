extends Node

# warning-ignore-all:unused_signal

# World
signal feature_tile_placed(feature)
signal feature_tile_left(feature)

signal generate_green_tile(feature)

signal spawn_event_request(event)

signal time_update(new_time)

signal world_is_ready

# Menu Navigation
signal push_menu(menu, context) # context is entirely dependent on the menu that was pushed
signal pop_menu
signal change_compact_resource(rec_id) # this signal should only be used when the inventory screen is already up, it opens the compact sub-menu

# Resources
signal resource_changed(type, new_val)
signal hope_gained(amount)

# Inventory
signal item_used(item_data)

# Resources
signal attempt_sleep()

# Disasters
signal disaster_damage(damage)
signal start_nightfall()
signal start_deep_nightfall()
signal night_penalty()
signal rain(period)
