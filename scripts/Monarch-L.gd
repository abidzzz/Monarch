extends CharacterBody3D


var player = null
var state_machine
var health = 100
var attack_name = null
var attacked = false

const SPEED = 4.0
var ATTACK_RANGE = 2.5
var attackOptions = ["SpinAttack", "aboveSlash", "outslash", "slash"]
var summoned_skeleton = false
var attack_timer: Timer

@export var player_path  ="../player"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree



# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	attack_timer = $Timer
	attack_timer.start()
	_choose_attack()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"SwordRun":
			# Navigation

			nav_agent.set_target_position(player.global_transform.origin)
			#velocity = (player.global_transform.origin - global_transform.origin).normalized() * SPEED
			
			velocity = (nav_agent.get_next_path_position() - global_transform.origin).normalized() * SPEED
			
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"idle":
			#rotation.y = lerp_angle(rotation.y, atan2(player.global_position.x, player.global_position.z), delta * 10.0)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 0.1)

	
	if _target_in_range() :
		for i in attackOptions:
			anim_tree.set("parameters/conditions/"+i, false)
		
		
		anim_tree.set("parameters/conditions/SwordRun", false)
		anim_tree.set("parameters/conditions/idle", true)
		
		if !attack_timer.is_stopped() and player.HEALTH > 0 :
			anim_tree.set("parameters/conditions/"+attack_name, _target_in_range())
			#await anim_tree.animation_finished
			#attacked = true
		else:
			reset_all_animation_conditions()
	else:
		for i in attackOptions:
			anim_tree.set("parameters/conditions/"+i, false)
		
		anim_tree.set("parameters/conditions/idle",false)		
		anim_tree.set("parameters/conditions/SwordRun",true)		
	#anim_tree.set("parameters/conditions/", !_target_in_range())

	if health <= 30 and not summoned_skeleton:
		summon_skeleton()
		
	if health <= 0:
		for i in attackOptions:
			anim_tree.set("parameters/conditions/"+i, false)
		anim_tree.set("parameters/conditions/die", true)


	move_and_slide()


func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _choose_attack():
	var randomIndex = randi() % attackOptions.size()
	attack_name = attackOptions[randomIndex]
	attacked = false
	

func summon_skeleton():
	for i in attackOptions:
		anim_tree.set("parameters/conditions/"+i, false)
	anim_tree.set("parameters/conditions/SwordRun", false)
	anim_tree.set("parameters/conditions/Summon", true)
	
	summoned_skeleton = true
	var skeleton_instance = preload("res://scenes/skeleton.tscn").instantiate()
	var boss_position = global_transform.origin
	var spawn_offset = Vector3(0, 0, -2)  # Adjust this offset
	skeleton_instance.global_transform.origin = boss_position + spawn_offset
	get_parent().add_child(skeleton_instance)



func play_walk():
	$Audio/walk.play()

func swing():
	$Audio/swing.play()
	
func swing2():
	$Audio/Swing2.play()


func take_damage():
	health -= 3
	$Audio/Damage.play()

func _on_hit_box_body_entered(_body):
	if anim_tree.animation_started and state_machine.get_current_node() not in ['idle','SwordRun','idle','DrawSword'] :
		player.take_damage()

func reset_all_animation_conditions():
	for i in attackOptions:
		anim_tree.set("parameters/conditions/" + i, false)
	anim_tree.set("parameters/conditions/SwordRun", false)
	anim_tree.set("parameters/conditions/idle", false)
	anim_tree.set("parameters/conditions/Summon", false)
	anim_tree.set("parameters/conditions/die", false)
	# Add other conditions as needed


func _on_timer_timeout():
	reset_all_animation_conditions()
	_choose_attack()
	attack_timer.start()
