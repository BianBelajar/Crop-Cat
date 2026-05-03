extends NodeState

@export var player : Player
@export var animated_sprite : AnimatedSprite2D
@export var hit_component_collision_shape : CollisionShape2D

@onready var spray_particles = preload("res://scenes/objects/particles/pesticide_particles.tscn")

func _on_enter() -> void:
	# KITA CONTEK PERSIS LOGIKA DARI WATERING_STATE
	if player.player_direction == Vector2.UP:
		animated_sprite.play("watering_back")
		hit_component_collision_shape.position = Vector2(0, -18)
	elif player.player_direction == Vector2.RIGHT:
		animated_sprite.play("watering_right")
		hit_component_collision_shape.position = Vector2(9, 0)
	elif player.player_direction == Vector2.DOWN:
		animated_sprite.play("watering_front")
		hit_component_collision_shape.position = Vector2(0, 3)
	elif player.player_direction == Vector2.LEFT:
		animated_sprite.play("watering_left")
		hit_component_collision_shape.position = Vector2(-9, 0)
	else:
		animated_sprite.play("watering_front")
		hit_component_collision_shape.position = Vector2(0, 3)
		
	# Nyalakan tabrakannya
	hit_component_collision_shape.disabled = false
	
	# Munculkan uap pestisida pas di posisi kotak merahnya
	if spray_particles:
		var spray = spray_particles.instantiate()
		player.add_child(spray)
		spray.global_position = player.global_position + hit_component_collision_shape.position
		get_tree().create_timer(1.0).timeout.connect(spray.queue_free)

func _on_next_transitions() -> void:
	if !animated_sprite.is_playing():
		transition.emit("Idle")

func _on_exit() -> void:
	animated_sprite.stop()
	# Matikan tabrakannya saat beres
	hit_component_collision_shape.disabled = true
