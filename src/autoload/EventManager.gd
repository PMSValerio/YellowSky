extends Node

# warning-ignore-all:unused_signal

# Menu Navigation
signal push_menu(menu, context) # context is entirely dependent on the menu that was pushed
signal pop_menu

# Resources
signal resource_changed(type, new_val)

# Inventory
signal item_used(item_data)

# World
signal disaster_damage(damage)
