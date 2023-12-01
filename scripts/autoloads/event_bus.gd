extends Node

# Stage control
signal reset_stage
signal stage_complete
signal load_stage(stage_path:String)
signal unload_stage
signal stage_loaded

# Game logic
signal player_died

# Music
signal play_song(stream:AudioStream)

# Save and Load
#signal player_data_ready
