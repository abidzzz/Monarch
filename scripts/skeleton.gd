extends CharacterBody3D


var player = null
var state_machine
var health = 100

const SPEED = 4.0
const ATTACK_RANGE = 2.0


@export var player_path = "../player"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

@onready var progress_bar = $Skeleton/SubViewport/ProgressBar
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"run":
			# Navigation

			nav_agent.set_target_position(player.global_transform.origin)
			
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (player.global_transform.origin - global_transform.origin).normalized() * SPEED
			#velocity = (nav_agent.get_next_location() - global_transform.origin).normalized() * SPEED
			
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
	# Conditions

	anim_tree.set("parameters/conditions/run", !_target_in_range())
		
	if _target_in_range() and player.HEALTH > 0:
		anim_tree.set("parameters/conditions/attack",true)
	else:
		anim_tree.set("parameters/conditions/attack", false)
	if player.HEALTH < 0:
		anim_tree.set("parameters/conditions/idle", true)

	if health <= 0:
		anim_tree.set("parameters/conditions/attack", false)
		anim_tree.set("parameters/conditions/run", false)
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(3.4).timeout
		queue_free()
	update_health()
	move_and_slide()


func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func update_health():
	progress_bar.value = health

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		player.take_damage()
		
func take_damage():
	health -= 10