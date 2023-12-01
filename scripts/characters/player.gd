class_name Player extends CharacterBody2D

const SPEED = 300.0
const STOMP_BOOST = 300
const FRICTION = 1
const BOUNCE_FACTOR = 1.3
const MAX_HORIZONTAL_VELOCITY = 800
const MAX_UP_VELOCITY = -650
const MAX_DOWN_VELOCITY = 1000
const SPIKE_LAYER_BITMASK = 32 #no idea why this is 32

@export var death_particle:PackedScene
@export_category("Jump Stuff")
@export var jump_height : float = 65
@export var jump_time_to_peak: float = .3
@export var jump_time_to_descent: float = .25 ## Time it takes to fall from jump height

# These are negative because 2D y-axis -- A lot of this math is no longer precisely 
# correct because of "hold to jump higher" logic, but the values stay. 
@onready var jump_velocity: float = (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity: float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
@onready var jump_start_velocity = .6 * jump_velocity #applied instantaneously at start of jump
#applied over time while jump is held
@onready var jump_acceleration_time = .15
# that magic number is what gives the jump its SAUCE
@onready var jump_hold_acceleration = ((jump_velocity - jump_start_velocity) * 1.25) / jump_acceleration_time

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var animation_state:AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var floor_detector = $FloorDetector

#Shield Collision Shapes
@onready var shield_collision_shape_up = $ShieldCollisionShapeUp as CollisionShape2D
@onready var shield_collision_shape_down = $ShieldCollisionShapeDown as CollisionShape2D
@onready var shield_collision_shape_left = $ShieldCollisionShapeLeft as CollisionShape2D
@onready var shield_collision_shape_right = $ShieldCollisionShapeRight as CollisionShape2D

#Sound Players
@onready var bounce_sound_player = $BounceSoundPlayer
@onready var victory_sound_player = $VictorySoundPlayer
@onready var death_sound_player = $DeathSoundPlayer
@onready var walk_sound_player = $WalkSoundPlayer as AudioStreamPlayer

#Timers
@onready var jump_lockout_timer = $JumpLockoutTimer as Timer
@onready var bounce_lockout_timer = $BounceLockoutTimer as Timer
@onready var jump_acceleration_timer = $JumpAccelerationTimer as Timer
@onready var bounce_sound_lockout_timer = $BounceSoundLockoutTimer
@onready var air_steer_delay_timer = $AirSteerDelayTimer

var blocking:bool
var dying:bool
#State machine & states
@onready var state_machine = $StateMachine

var facing_dir: float = 1
var block_dir:Vector2:
	set(value):
		set_shield_collision_shape(value)
		match(value):
			Vector2.ZERO:
				block_dir = value
				blocking = false
			Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT:
				block_dir = value
				blocking = true
		
var prior_velocity:Vector2 = Vector2.ZERO
	
func _ready():
	Globals.player = self
	animation_tree.active = true
	jump_acceleration_timer.wait_time = jump_acceleration_time
	
func set_shield_collision_shape(direction:Vector2):
	shield_collision_shape_down.disabled = true
	shield_collision_shape_up.disabled = true
	shield_collision_shape_left.disabled = true
	shield_collision_shape_right.disabled = true
	
	match(direction):
		Vector2.UP:
			shield_collision_shape_up.disabled = false
		Vector2.DOWN:
			shield_collision_shape_down.disabled = false
		Vector2.LEFT:
			shield_collision_shape_left.disabled = false
		Vector2.RIGHT:
			shield_collision_shape_right.disabled = false
	
func clamp_and_save_velocity():
	velocity = velocity.clamp(Vector2(-MAX_HORIZONTAL_VELOCITY, MAX_UP_VELOCITY), \
		Vector2(MAX_HORIZONTAL_VELOCITY, MAX_DOWN_VELOCITY))
	prior_velocity = velocity
	
func physics_process(delta:float): #note the lack of underscore!
	block_dir = Input.get_vector("shield_left", "shield_right", "shield_up", "shield_down").snapped(Vector2(1, 1))
	
	if !jump_acceleration_timer.is_stopped():
		velocity.y += jump_hold_acceleration * delta
	
	set_facing_dir()
	handle_movement(delta)
	
func handle_movement(delta:float):
	var collision_count = 0
	const MAX_COLLISIONS = 10
	var collision = move_and_collide(velocity * delta)
	while collision and collision_count < MAX_COLLISIONS:
		collision_count += 1
		var collider := collision.get_collider()
		var layer = PhysicsServer2D.body_get_collision_layer(collision.get_collider_rid())
		var normal = collision.get_normal()
		var opposite = normal * -1
		
		var deflect_angle = PI / 2
		if layer == SPIKE_LAYER_BITMASK or collider is Fireball or collider is \
		Projectile or collider is Skellington or collider is Bat: #this is a mess
			#this ain't the collision angle, it's just the block angle. you can
			#bounce when pointing 90 degrees off target
			var angle = abs(block_dir.angle_to(opposite))
			if collider is Skellington or collider is Bat:
				if angle < deflect_angle and block_dir != Vector2.ZERO:
					if block_dir == Vector2.DOWN:
						if collider is Skellington:
							collider.die()
						elif collider is Bat:
							collider.bounce()
					bounce(normal)
					collision = move_and_collide(velocity * delta)
				else:
					die()
			elif (block_dir == Vector2.ZERO or angle >= deflect_angle) and !dying:
				die()
				if collider is Projectile:
					collider.queue_free()
			# Shared bounce condition
			elif angle < deflect_angle and block_dir != Vector2.ZERO and bounce_lockout_timer.is_stopped():
				if layer == SPIKE_LAYER_BITMASK:
					bounce(normal, true)
					collision = move_and_collide(velocity * delta)
				elif collider is Fireball:
					collider.deflect(opposite)
					bounce(normal)
					collision = move_and_collide(velocity * delta)
				elif collider is Projectile and !collider.deflected:
					play_bounce_sound()
					collider.deflect(opposite)
					animation_player.play("squash_horizontal")
					collision = move_and_collide(velocity * delta)
		else:
			velocity = velocity.slide(collision.get_normal())		
			collision = move_and_collide(velocity * delta)
		
func _input(event):
	if event.is_action_released("reload"):
		die()

func is_touching_floor():
	return floor_detector.has_overlapping_bodies()
	
func get_direction() -> float:
	var direction = snapped(Input.get_axis("move_left", "move_right"), 1)
	return direction
	
func set_facing_dir():
	var direction = get_direction()
	if direction != 0:
		facing_dir = direction
	
func apply_gravity(delta:float):
	velocity.y += get_gravity() * delta
	
func get_gravity():
	return jump_gravity if velocity.y < 0 else fall_gravity
	
func jump() -> bool: #returns whether jump was successful
	if jump_lockout_timer.is_stopped():
		jump_acceleration_timer.start()
		animation_state.travel("JumpStateMachine")
		velocity.y += jump_start_velocity#jump_velocity
		jump_lockout_timer.start()
		return true
	return false
	
func stop_jumping():
	jump_acceleration_timer.stop()
	
# Set player's horizontal velocity, but don't slow the player down if he's holding a direction
func build_horizontal_speed(delta:float): 
	if !air_steer_delay_timer.is_stopped():
#		print("Air steer delay!")
		return
	var direction = get_direction()
	#if the player isn't already going faster than running speed 
	if abs(velocity.x) < SPEED \
	or (direction < 0) != (velocity.x < 0): #or if they're inputting opposite their movement
		velocity.x = move_toward(velocity.x, direction * SPEED, 1500 * delta)
	
func bounce(normal:Vector2, can_vertical_boost:= false): #bounce the player based on shield position
	normal = normal.snapped(Vector2(1, 1)).normalized()
	match(normal):	
		Vector2.UP: #bouncing by blocking down
#			if abs(velocity.x) / abs(velocity.y) > 8: #if velocity is 90%+ horizontal
#				velocity = velocity.slide(normal) * 1.1
#				if bounce_sound_lockout_timer.is_stopped():
#					animation_player.play("squash_vertical")
#					play_bounce_sound()
#					bounce_sound_lockout_timer.start()
#			else:
			animation_player.play("squash_vertical")
			velocity = velocity.bounce(normal) * BOUNCE_FACTOR
		Vector2.LEFT, Vector2.RIGHT:
			if can_vertical_boost: #only used for sideways spike bouncing
				velocity = velocity.slerp(Vector2(400 * normal.x, -350), .8)
				air_steer_delay()
			else:
				velocity = velocity.bounce(normal) * BOUNCE_FACTOR
			animation_player.play("squash_horizontal")
		Vector2.DOWN, _:
			velocity = velocity.bounce(normal) * BOUNCE_FACTOR
			if abs(normal.x) > abs(normal.y):
				animation_player.play("squash_horizontal")
			else:
				animation_player.play("squash_vertical")
				
	play_bounce_sound()
	bounce_lockout_timer.start()
	jump_lockout_timer.start()

func air_steer_delay():
	air_steer_delay_timer.start()
	
func play_bounce_sound():
	bounce_sound_player.pitch_scale = randf_range(.8, 1)
	bounce_sound_player.play()
	
func die():
	if not dying:
		EventBus.player_died.emit()
		dying = true
		set_deferred("process_mode", PROCESS_MODE_DISABLED)
		sprite_2d.hide()
		death_sound_player.play()
		var particles = death_particle.instantiate() as Particle
		particles.global_position = global_position
		get_parent().add_child(particles)
		await particles.finished
		EventBus.reset_stage.emit()
		if !StageManager.current_stage: #if running a stage scene alone
			get_tree().reload_current_scene()

func _on_victory_zone_detector_body_entered(body):
	EventBus.stage_complete.emit()
	get_tree().paused = true
	victory_sound_player.play()
	await victory_sound_player.finished
