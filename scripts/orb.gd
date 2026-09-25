extends Area2D

@export var explosion_scene: PackedScene

@onready var collect_audio: AudioStreamPlayer2D = $CollectAudio

signal collected

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		collected.emit()
		
		if explosion_scene:
			var explosion = explosion_scene.instantiate()
			explosion.global_position = global_position
			get_parent().add_child(explosion)			
		
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		
		collect_audio.play()
		await collect_audio.finished
		
		queue_free()
