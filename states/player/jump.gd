class_name PlayerJump extends StateMachineState

@onready var player:Player = owner
@onready var player_run = $"../PlayerRun"
@onready var player_glide = $"../PlayerGlide"
@onready var player_slide = $"../PlayerSlide"
@onready var coyote_timer = $"../../CoyoteTimer" as Timer
@onready var jump_buffer_timer = $"../../JumpBufferTimer" as Timer

# Called when the state machine enters this state.
func on_enter():
	if player.block_dir == Vector2.UP:
		state_machine.current_state = player_glide
		return
	elif player.block_dir == Vector2.DOWN:
		state_machine.current_state = player_slide
		return
	#this fixes a bug that lets you benefit from coyote time after down-bouncing
	# - James calls it a "zero day tech" so maybe it's good
	if state_machine._previous_state != player_slide:	
		coyote_timer.start()
	await player.animation_player.animation_finished
	
# Called every physics frame when this state is active.
func on_physics_process(delta):
	player.clamp_and_save_velocity()
	player.apply_gravity(delta)
	player.build_horizontal_speed(delta)
	player.physics_process(delta)
	handle_state_change()

# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		if coyote_timer.time_left > 0.0: # coyote time!
			if player.jump():
				print("Coyote time!")			
		else:
			jump_buffer_timer.start()
	elif event.is_action_released("jump"):
		player.stop_jumping()

func handle_state_change():
	if player.is_touching_floor():
		##if the player input a jump just before touchdown and is still holding the input
		if jump_buffer_timer.time_left > 0 and Input.is_action_pressed("jump"): 
			print("Buffered jump!")
			player.jump()
		else:
			state_machine.current_state = player_run
			return
		
	match(player.block_dir):
		Vector2.UP:
			state_machine.current_state = player_glide
		Vector2.DOWN:
			state_machine.current_state = player_slide
			
# Called when the state machine exits this state.
func on_exit():
	pass

