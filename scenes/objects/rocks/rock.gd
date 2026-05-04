# =============================================================================
# rock.gd  —  VERSI DIPERBARUI
# Lokasi: res://scenes/objects/rocks/rock.gd
#
# PERUBAHAN:
#   • on_max_damage_reached() kini spawn 1 ATAU 2 stone secara acak
#     menggunakan randi_range(1, 2)
#   • Masing-masing stone punya offset posisi acak
# =============================================================================
extends Sprite2D

@onready var hurt_component: HurtComponent     = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent

var stone_scene = preload("res://scenes/objects/rocks/stone.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)

func on_hurt(hit_damage: int) -> void:
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 0.3)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("shake_intensity", 0.0)

func on_max_damage_reached() -> void:
	# ── DIPERBARUI: Drop 1 atau 2 stone secara acak ──────────────────────
	var drop_amount: int = randi_range(1, 2)

	for i in range(drop_amount):
		var stone_instance: Node2D = stone_scene.instantiate() as Node2D
		get_parent().add_child(stone_instance)
		# Offset acak agar stone tidak bertumpuk
		var offset = Vector2(randf_range(-14.0, 14.0), randf_range(-14.0, 14.0))
		stone_instance.global_position = global_position + offset

	queue_free()

func add_stone_scene() -> void:
	var stone_instance: Node2D = stone_scene.instantiate() as Node2D
	stone_instance.global_position = global_position
	get_parent().add_child(stone_instance)
