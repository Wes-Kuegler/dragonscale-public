extends Path2D

@onready var path_follow_2d = $PathFollow2D as PathFollow2D
@onready var bat = $PathFollow2D/Bat as Bat

@export var progress_increment = 50
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path_follow_2d.progress += progress_increment * delta
	bat.sprite_2d.flip_h = path_follow_2d.progress_ratio < .5
#	if path_follow_2d.progress_ratio >= 1 or path_follow_2d.progress_ratio <= 0:
#		progress_increment *= 1
