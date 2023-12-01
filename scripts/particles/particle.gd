class_name Particle extends GPUParticles2D

signal finished

func _ready():
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	finished.emit()
	queue_free()
