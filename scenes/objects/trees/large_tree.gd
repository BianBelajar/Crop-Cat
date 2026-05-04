# =============================================================================
# large_tree.gd  —  VERSI DIPERBARUI
# Lokasi: res://scenes/objects/trees/large_tree.gd
#
# PERUBAHAN:
#   • on_max_damage_reached() kini spawn 2 log (bukan 1)
#   • Masing-masing log punya offset posisi acak agar tidak menumpuk
# =============================================================================
extends Sprite2D

@onready var hurt_component: HurtComponent     = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent

var log_scene = preload("res://scenes/objects/trees/log.tscn")

## Jumlah log yang dijatuhkan saat pohon besar ditebang.
const LOG_DROP_COUNT: int = 2

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)

func on_hurt(hit_damage: int) -> void:
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 0.5)
	await get_tree().create_timer(1.0).timeout
	material.set_shader_parameter("shake_intensity", 0.0)

func on_max_damage_reached() -> void:
	# ── DIPERBARUI: Spawn 2 log ──────────────────────────────────────────
	for i in range(LOG_DROP_COUNT):
		var log_instance: Node2D = log_scene.instantiate() as Node2D
		get_parent().add_child(log_instance)
		# Offset acak agar kedua log tidak bertumpuk persis
		var offset = Vector2(randf_range(-16.0, 16.0), randf_range(-16.0, 16.0))
		log_instance.global_position = global_position + offset

	queue_free()

func add_log_scene() -> void:
	var log_instance: Node2D = log_scene.instantiate() as Node2D
	log_instance.global_position = global_position
	get_parent().add_child(log_instance)
