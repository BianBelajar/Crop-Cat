extends Node2D

var wheat_harvest_scene = preload("res://scenes/objects/plants/wheat_harvest.tscn")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var watering_particles: GPUParticles2D = $WateringParticles
@onready var flowering_particles: GPUParticles2D = $FloweringParticles
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component: HurtComponent = $HurtComponent

@export_range(0, 1) var pest_chance: float = 0.20 # Sudah 20% mantap!

var growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Seed
var has_pest: bool = false 

func _ready() -> void:
	if randf() <= pest_chance:
		spawn_pest()
	watering_particles.emitting = false
	flowering_particles.emitting = false
	
	hurt_component.hurt.connect(on_hurt)
	growth_cycle_component.crop_maturity.connect(on_crop_maturity)
	growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)

func spawn_pest() -> void:
	has_pest = true
	flowering_particles.emitting = true
	print("Padi kena hama Kutu Kebul!")

func _process(delta: float) -> void:
	growth_state = growth_cycle_component.get_current_growth_state()
	sprite_2d.frame = growth_state
	
	# Bagian yang tadi diperbaiki:
	if growth_state == DataTypes.GrowthStates.Maturity:
		if has_pest:
			flowering_particles.emitting = true
		else:
			flowering_particles.emitting = false
	
func on_hurt(hit_damage: int) -> void:
	if !growth_cycle_component.is_watered:
		watering_particles.emitting = true
		await get_tree().create_timer(5.0).timeout
		watering_particles.emitting = false
		growth_cycle_component.is_watered = true
		
func on_crop_maturity() -> void:
	if has_pest:
		flowering_particles.emitting = true
	else:
		flowering_particles.emitting = false

func on_crop_harvesting() -> void:
	var drop_amount = randi_range(1, 1) 
	
	for i in range(drop_amount):
		var wheat_harvest_instance = wheat_harvest_scene.instantiate() as Node2D
		get_parent().add_child(wheat_harvest_instance)
		
		var random_offset = Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
		wheat_harvest_instance.global_position = global_position + random_offset
		
	queue_free()
