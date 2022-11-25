extends Node

# warning-ignore-all:unused_signal

# Menu Navigation
signal push_menu(menu, context) # context is entirely dependent on the menu that was pushed
signal pop_menu

# Inventory
signal item_used(item_data)
