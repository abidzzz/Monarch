extends Node

signal OnCombatBegin
signal OnCombatEnd

@export var HandContainer: Node3D;
@export var HipContainer: Node3D;
@export var ItemContainer: Node3D;
@export var upperBodyStatePlaybackPath: String;
@export var oneHandStanceName: String;
@export var twoHandStanceName: String;
@onready var player = $"../../.."

@export var animationTree: AnimationTree;

var isInCombat: bool;
var usingTwoHands: bool;


var comboTimer = 0
var comboTimeLimit = 0.5  # Adjust the time limit as needed



func _input(event):
	if Input.is_action_just_pressed("DrawWeapon"):
		var playback = animationTree.get(upperBodyStatePlaybackPath) as AnimationNodeStateMachinePlayback;
		if !isInCombat:
			isInCombat = true
			OnCombatBegin.emit()
			if usingTwoHands:
				playback.travel(twoHandStanceName + "Idle")
			else:
				player.can_move = false
				playback.travel(oneHandStanceName + "Idle")
				await animationTree.animation_finished
				player.can_move = true
		else:
			isInCombat = false
			OnCombatEnd.emit()
			playback.travel("Idle")
	if isInCombat:
		if Input.is_action_just_pressed("SwapHands"):
			var playback = animationTree.get(upperBodyStatePlaybackPath) as AnimationNodeStateMachinePlayback;
			if usingTwoHands:
				
				playback.travel(oneHandStanceName + "Idle")
			else:
				playback.travel(twoHandStanceName + "Idle")
			usingTwoHands = !usingTwoHands
		
		if Input.is_action_just_pressed("UseWeapon"):
			var playback = animationTree.get(upperBodyStatePlaybackPath) as AnimationNodeStateMachinePlayback;
			if usingTwoHands:
				playback.travel(twoHandStanceName + "Combo")
			else:
				
				player.can_move = false
				#player.look_at(Vector3(player.monarch_l.global_position.x, player.global_position.y, player.monarch_l.global_position.z), Vector3.UP)
				playback.travel(oneHandStanceName + "Slash")
				await animationTree.animation_finished
				player.can_move = true

		if Input.is_action_just_pressed("UseCombo"):
			var playback = animationTree.get(upperBodyStatePlaybackPath) as AnimationNodeStateMachinePlayback;
			if usingTwoHands:
				
				playback.travel(twoHandStanceName + "Combo")
			else:
				player.can_move = false
				playback.travel(oneHandStanceName + "Combo")
				await animationTree.animation_finished
				player.can_move = true
func EquipWeapon():
	var parent = ItemContainer.get_parent()
	parent.remove_child(ItemContainer)
	HandContainer.add_child(ItemContainer)
	ItemContainer.position = Vector3.ZERO
	ItemContainer.rotation_degrees = Vector3.ZERO
	$"../../../Audio/DrawSword".play()
func UnEquipWeapon():
	var parent = ItemContainer.get_parent()
	parent.remove_child(ItemContainer)
	HipContainer.add_child(ItemContainer)
	ItemContainer.position = Vector3.ZERO
	ItemContainer.rotation_degrees = Vector3.ZERO
