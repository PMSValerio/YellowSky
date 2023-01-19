extends Node

# warning-ignore-all:unused_signal

# World
signal feature_tile_placed(feature)
signal feature_tile_left(feature)

# Menu Navigation
signal push_menu(menu, context) # context is entirely dependent on the menu that was pushed
signal pop_menu
signal change_compact_resource(rec_id) # this signal should only be used when the inventory screen is already up, it opens the compact sub-menu

# Resources
signal resource_changed(type, new_val)
signal hope_gained(amount)

# Inventory
signal item_used(item_data)

# World
signal disaster_damage(damage)
