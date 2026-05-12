# =============================================================================
# wheat.gd — VERSI DIPERBAIKI
# Lokasi: res://scenes/objects/plants/wheat.gd
#
# PERBAIKAN:
#   • Tambah call QuestManager.notify_planted() di _ready() untuk
#     tracking achievement "plant_10".
#   • Semua kode lama dipertahankan persis sama.
# =============================================================================
extends Node2D

var wheat_harvest_scene = preload("res://scenes/objects/plants/wheat_harvest.tscn")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var watering_particles: GPUParticles2D = $WateringParticles
@onready var flowering_particles: GPUParticles2D = $FloweringParticles
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component: HurtComponent = $HurtComponent

@export_range(0, 1) var pest_chance: float = 0.20

var growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Seed
var has_pest: bool = false

const DEAD_FRAME: int = 6


func _ready() -> void:
	if randf() <= DifficultyManager.pest_chance:
		spawn_pest()

	watering_particles.emitting = false
	flowering_particles.emitting = false

	hurt_component.hurt.connect(on_hurt)
	growth_cycle_component.crop_maturity.connect(on_crop_maturity)
	growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)

	# ─── Tracking Achievement: plant_10 ──────────────────────────────────
	print("🌱 Gandum ditanam — melaporkan ke QuestManager untuk tracking plant_10")
	QuestManager.notify_planted()


# =============================================================================
# SPAWN & PESTICIDE
# =============================================================================
func spawn_pest() -> void:
	has_pest = true

func apply_pesticide() -> void:
	if has_pest:
		has_pest = false
		flowering_particles.emitting = false
		modulate = Color(1, 1, 1)


# =============================================================================
# MATI
# =============================================================================
func show_dead_sprite() -> void:
	flowering_particles.emitting = false
	watering_particles.emitting = false
	sprite_2d.frame = DEAD_FRAME
	modulate = Color(0.6, 0.6, 0.6, 1.0)


# =============================================================================
# _process
# =============================================================================
func _process(_delta: float) -> void:
	growth_state = growth_cycle_component.get_current_growth_state()
	sprite_2d.frame = growth_state

	if has_pest and growth_state >= DataTypes.GrowthStates.Maturity:
		flowering_particles.emitting = true
		modulate = Color(0.904, 0.589, 0.1, 1.0)
	else:
		flowering_particles.emitting = false
		modulate = Color(1, 1, 1)


# =============================================================================
# ON HURT
# =============================================================================
func on_hurt(_hit_damage: int) -> void:
	if ToolManager.selected_tool == DataTypes.Tools.Pesticide:
		if has_pest:
			apply_pesticide()
		return

	if not growth_cycle_component.is_watered:
		watering_particles.emitting = true
		await get_tree().create_timer(5.0).timeout
		watering_particles.emitting = false
		growth_cycle_component.is_watered = true


# =============================================================================
# MATURITY & HARVEST
# =============================================================================
func on_crop_maturity() -> void:
	if has_pest:
		flowering_particles.emitting = true
	else:
		flowering_particles.emitting = false

func on_crop_harvesting() -> void:
	if has_pest:
		queue_free()
		return

	var drop_amount: int = randi_range(1, 1)
	for i in range(drop_amount):
		var instance = wheat_harvest_scene.instantiate() as Node2D
		get_parent().add_child(instance)
		var offset = Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
		instance.global_position = global_position + offset

	queue_free()


# =============================================================================
# SAVE / LOAD
# =============================================================================
func get_plant_save_data() -> Dictionary:
	var data: Dictionary = growth_cycle_component.get_save_data()
	data["has_pest"] = has_pest
	return data

func apply_plant_save_data(data: Dictionary) -> void:
	has_pest = data.get("has_pest", false)
	growth_cycle_component.apply_save_data(data)
