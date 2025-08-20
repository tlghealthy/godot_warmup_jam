extends Node

signal item_added(item_name: String, quantity: int)
signal item_removed(item_name: String, quantity: int)
signal inventory_changed

var items: Dictionary = {}

func add_item(item_name: String, quantity: int = 1) -> void:
	if items.has(item_name):
		items[item_name] += quantity
	else:
		items[item_name] = quantity
	
	item_added.emit(item_name, quantity)
	inventory_changed.emit()
	print("Added %d %s to inventory" % [quantity, item_name])

func remove_item(item_name: String, quantity: int = 1) -> bool:
	if not items.has(item_name) or items[item_name] < quantity:
		return false
	
	items[item_name] -= quantity
	if items[item_name] <= 0:
		items.erase(item_name)
	
	item_removed.emit(item_name, quantity)
	inventory_changed.emit()
	print("Removed %d %s from inventory" % [quantity, item_name])
	return true

func has_item(item_name: String, quantity: int = 1) -> bool:
	return items.has(item_name) and items[item_name] >= quantity

func get_item_count(item_name: String) -> int:
	return items.get(item_name, 0)

func get_all_items() -> Dictionary:
	return items.duplicate()

func clear_inventory() -> void:
	items.clear()
	inventory_changed.emit()
	print("Inventory cleared")

func print_inventory() -> void:
	print("=== INVENTORY ===")
	if items.is_empty():
		print("Empty")
	else:
		for item_name in items:
			print("%s: %d" % [item_name, items[item_name]])
	print("================")
