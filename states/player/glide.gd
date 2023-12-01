class_name PlayerGlide extends StateMachineState

@onready var player:Player = owner
@onready var player_run = $"../PlayerRun"
@onready var player_jump = $"../PlayerJump"
@onready var player_slide = $"../PlayerSlide"

@export var glide_acceleration = 1500
# Called when the state machine enters this state.
func on_enter():
	pass

# Called every physics frame when this state is active.
func on_physics_process(delta):
	player.clamp_and_save_velocity()
	if player.jump_acceleration_timer.is_stopped(): #not jumping
		player.velocity.y = move_toward(player.velocity.y, 100, delta * glide_acceleration)
	else:
		player.apply_gravity(delta)
	player.build_horizontal_speed(delta)
	player.physics_process(delta)
	handle_state_change()
		
func handle_state_change():
	if player.is_touching_floor():
		state_machine.current_state = player_run
		return
		
	match(player.block_dir):
		Vector2.DOWN:
			state_machine.current_state = player_slide
		Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT:
			state_machine.current_state = player_jump
			
# Called when the state machine exits this state.
func on_exit():
	pass

