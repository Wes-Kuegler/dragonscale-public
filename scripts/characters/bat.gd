class_name Bat extends AnimatableBody2D
@onready var animation_player = $AnimationPlayer
@export var facing_right := false ## Faces left by default.
@onready var animation_tree = $AnimationTree
@onready var sprite_2d = $Sprite2D

func _ready():
	animation_tree.active = true
	
#func _process(delta):
#	if Globals.player:
#		facing_right = global_position.x < Globals.player.global_position.x
		
func bounce():
	animation_player.play("squash")
