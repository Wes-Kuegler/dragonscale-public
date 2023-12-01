class_name PlayerSlide extends StateMachineState

@onready var player:Player = owner
@onready var player_run = $"../PlayerRun"
@onready var player_jump = $"../PlayerJump"
@onready var player_glide = $"../PlayerGlide"

# Called when the state machine enters this state.
func on_enter():
#	player.floor_detector_shape.disabled = false
	pass

# Called every physics frame when this state is active.
func on_physics_process(delta):
	player.clamp_and_save_velocity()
	var direction := player.get_direction()
	if player.is_touching_floor():
		player.velocity.x = lerp(player.velocity.x, 0.0, player.FRICTION * delta)
	else:
		player.apply_gravity(delta)
		if direction != 0:
			player.velocity.x = lerp(player.velocity.x, direction * player.SPEED, .05) 
	player.physics_process(delta)
	handle_state_change()
	

# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		if player.is_touching_floor():
			player.jump()
			state_machine.current_state = player_jump
			
func handle_state_change():
	match(player.block_dir):
		Vector2.UP:
			if player.is_touching_floor():
				state_machine.current_state = player_run
			else:
				state_machine.current_state = player_glide
		Vector2.LEFT, Vector2.RIGHT, Vector2.ZERO:
			if player.is_touching_floor():
				state_machine.current_state = player_run
			else:
				state_machine.current_state = player_jump
			
			
# Called when the state machine exits this state.
func on_exit():
#	player.floor_detector_shape.disabled = true
	pass
