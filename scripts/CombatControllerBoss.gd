extends Node
@export var HandContainer: Node3D;
@export var SpineContainer: Node3D;
@export var ItemContainer: Node3D;

func EquipWeapon():
	var parent = ItemContainer.get_parent()
	parent.remove_child(ItemContainer)
	HandContainer.add_child(ItemContainer)
	ItemContainer.position = Vector3.ZERO
	ItemContainer.rotation_degrees = Vector3.ZERO
	$"../Audio/DrawSword".play()
func UnEquipWeapon():
	var parent = ItemContainer.get_parent()
	parent.remove_child(ItemContainer)
	SpineContainer.add_child(ItemContainer)
	ItemContainer.position = Vector3.ZERO
	ItemContainer.rotation_degrees = Vector3.ZERO
