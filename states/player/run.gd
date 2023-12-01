class_name PlayerRun extends StateMachineState

@onready var player:Player = owner
@onready var player_jump = $"../PlayerJump"
@onready var player_slide = $"../PlayerSlide"

# Called when the state machine enters this state.
func on_enter():
	pass

# Called every physics frame when this state is active.
func on_physics_process(delta):	
	player.clamp_and_save_velocity()
	#magnitude check prevents weird single footstep sound at start of some stages
	if abs(player.velocity.x) > .1 and not player.walk_sound_player.playing:
		player.walk_sound_player.play()
	var direction := player.get_direction()
	player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, 2500 * delta)
	player.physics_process(delta)
	handle_state_change()

func handle_state_change():
	if !player.is_touching_floor():
		state_machine.current_state = player_jump
		return
	match(player.block_dir):
		Vector2.DOWN:
			state_machine.current_state = player_slide
			return
		
# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		player.jump()		
		state_machine.current_state = player_jump

# Called when the state machine exits this state.
func on_exit():
	pass

