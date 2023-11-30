extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/akai/AnimationPlayer
@onready var visuals = $visuals
@onready var animation_tree = $visuals/akai/AnimationTree
@onready var roll_window = $roll_window
@onready var yellow_bar = $"../../../../CanvasLayer/YellowBar"
@onready var health_bar = $"../../../../CanvasLayer/HealthBar"
@onready var stamina_bar = $"../../../../CanvasLayer/StaminaBar"
@onready var boss_health_bar = $"../../../../CanvasLayer/BossHealthBar"
@onready var yellow_boss_bar = $"../../../../CanvasLayer/YellowBossBar"


#@onready var skeleton = $"../Skeleton"
@onready var monarch_l = $"../Monarch-L"


@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var maxStamina: float = 100.0  # Maximum stamina capacity
@export var staminaRegenRate: float = 8.0  # Stamina regeneration rate per second
@export var staminaDepletionRate: float = 13.0
@onready var combat_controller = $visuals/akai/CombatController

const JUMP_VELOCITY = 4.5
var DAMAGE_AMOUNT = 5
var SPEED = 3.4
var HEALTH = 100
var STAMINA = 100
var walking_speed = 3.0
var running_speed = 10.0
var roll_magnitude = 17
var healcount = 1
var can_move = true
var reduced = false
var canHeal = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var currentInput: Vector2;
var currentVelocity: Vector2;
var direction = Vector3.BACK
var playback = null


var running = false
var roll = false
var regenerating = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	playback = animation_tree.get("parameters/UpperBody/playback") as AnimationNodeStateMachinePlayback;
	direction = (transform.basis * Vector3(currentInput.x, 0, currentInput.y)).normalized()
	update_bars()
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_horizontal))
		var new_vertical_rotation = camera_mount.rotation_degrees.x - event.relative.y * sens_vertical
		new_vertical_rotation = clamp(new_vertical_rotation, -40, 15 )  # Limit vertical rotation -40 is top 15 is bottom
		camera_mount.rotation_degrees.x = new_vertical_rotation



func _physics_process(delta):
	currentInput = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(currentInput.x, 0, currentInput.y)).normalized()
		
	if Input.is_action_pressed("Heal"):
		
		if HEALTH < 80 and canHeal:
			HEALTH += 15
			
			if not reduced :
				healcount -= 1
				reduced = true
				$HealParticle.show()
				await get_tree().create_timer(1.5).timeout
				$HealParticle.hide()
				
			
			$"../../../../CanvasLayer/TextureRect/RichTextLabel".text = str(healcount)

	
	canHeal = healcount > 0			
	if Input.is_action_pressed("run") and direction:
		if can_move:
			SPEED = running_speed
			running = true
			STAMINA -= staminaDepletionRate * delta
			regenerating = false
		

	else:
		if can_move:
			SPEED = walking_speed
			running = false
			roll = false

		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not regenerating:
		if STAMINA < maxStamina:
			STAMINA += staminaRegenRate * delta
		else:
			STAMINA = maxStamina
			
	if STAMINA < 15 :
		SPEED = walking_speed
		running = false
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	if direction:			
		visuals.look_at(position + direction)
		if can_move:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		var currentNormalizedVelocity = to_local(global_position + velocity).normalized()
		currentInput = Vector2(currentNormalizedVelocity.x, currentNormalizedVelocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		currentInput = Vector2.ZERO
	
	
	if combat_controller.isInCombat:
		animation_tree.set("parameters/UpperBody/conditions/Sword1Idle", currentInput == Vector2.ZERO && is_on_floor())
	else:
		animation_tree.set("parameters/UpperBody/conditions/idle", currentInput == Vector2.ZERO && is_on_floor())
	
	if running and direction:
		if can_move:
			if combat_controller.isInCombat:
				animation_tree.set("parameters/UpperBody/conditions/SwordRun", true)
				animation_tree.set("parameters/UpperBody/conditions/SwordWalk", false)
			else:
				animation_tree.set("parameters/UpperBody/conditions/RunForward", true)
				animation_tree.set("parameters/UpperBody/conditions/walk", false)
	else:
		if can_move:
			#animation_tree.set("parameters/UpperBody/conditions/roll", false)
			var walking = ( (currentInput.y == 1 || currentInput.y == -1) || (currentInput.x == 1 || currentInput.x == -1))  && is_on_floor() 
			if combat_controller.isInCombat:
				
				animation_tree.set("parameters/UpperBody/conditions/SwordRun", false)
				
				animation_tree.set("parameters/UpperBody/conditions/SwordWalk", walking)
			else:
				animation_tree.set("parameters/UpperBody/conditions/RunForward", false)
				animation_tree.set("parameters/UpperBody/conditions/walk", walking  )
	if monarch_l.health <= 0:
		boss_health_bar.hide()
		yellow_boss_bar.hide()
		
		$"../../../../CanvasLayer/RichTextLabel".hide()
		$"../../../../AnimationPlayer".play("won")
		await get_tree().create_timer(3).timeout
		$"../../../../CanvasLayer/Text".hide()
		$"../../../../CanvasLayer/credits".show()
		await get_tree().create_timer(5).timeout
		$"../../../../AnimationPlayer".play("fade")
		get_tree().change_scene_to_file("res://scenes/startmenu.tscn")
		
	if HEALTH <= 0:	
		can_move = false	
		var options = ['idle','walk','SwordRun','SwordWalk', 'Sword1HandIdle']
		for i in options:
			animation_tree.set("parameters/UpperBody/conditions/"+i, false)
		animation_tree.set("parameters/UpperBody/conditions/die", true)
		$"../../../../AnimationPlayer".play("DED")
		await get_tree().create_timer(5).timeout
		
		

		$"../../../../CanvasLayer/credits".show()
		$"../../../../AnimationPlayer".play("fade")
		await get_tree().create_timer(5).timeout
		
		get_tree().change_scene_to_file("res://scenes/startmenu.tscn")
		
	move_and_slide()
	update_bars()

func update_bars():
	health_bar.value = HEALTH
	stamina_bar.value = STAMINA
	boss_health_bar.value = monarch_l.health
	var tween = create_tween()
	tween.tween_property(yellow_bar,"value", HEALTH , 1).set_ease(Tween.EASE_IN_OUT)
	var boss_tween = create_tween()
	boss_tween.tween_property(yellow_boss_bar,"value", monarch_l.health , 1).set_ease(Tween.EASE_IN_OUT)
		
func take_damage():
	HEALTH -= DAMAGE_AMOUNT
	if HEALTH >= 0:
		$Audio/damage.play()
	update_bars()
	

func _on_hit_box_body_entered(body):
	
	if animation_tree.animation_started and playback.get_current_node() not in ['Walking','Sword1HandRun','Sword1HandDraw','Sword1HandWalk','Idle','Sword1HandIdle','RunForward'] :
		body.take_damage()
		#skeleton.health -= 10

func swing():
	$Audio/sword_swing.play()
	
func swing2():
	$Audio/sword_swing2.play()



