class_name GrowthCycleComponent
extends Node


@export var current_growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Germination
@export_range(5,365) var days_until_harvest: int = 7

signal crop_maturity
signal crop_harvesting

var is_watered: bool
var growth_points: float = 0.0
var starting_day: int
var current_day : int

func _ready() -> void:
	DayAndNightCycleManager.time_tick_day.connect(on_time_tick_day)

func on_time_tick_day(day : int) -> void:
	if is_watered:
		# Jika tanaman punya hama, kasih penalti (hanya dapat 0.5 poin per hari)
		# Jika sehat, dapat 1.0 poin per hari.
		var increment = 1.0
		if get_parent().has_pest:
			increment = 0.5 
		
		growth_points += increment
		
		# Gunakan growth_points (angka bulat) untuk menghitung tahap
		var effective_days = int(growth_points)
		
		# Jalankan logika pertumbuhan dengan angka progres kita
		growth_states_new_logic(effective_days)
		harvest_state_new_logic(effective_days)

func growth_states_new_logic(days_passed: int):
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		return
	
	var num_states = 5
	var states_index = (days_passed % num_states) + 1
	
	if states_index != current_growth_state:
		current_growth_state = states_index
		if current_growth_state == DataTypes.GrowthStates.Maturity:
			crop_maturity.emit()

func harvest_state_new_logic(days_passed: int) -> void:
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		if days_passed >= days_until_harvest:
			crop_harvesting.emit()

func growth_states(starting_day: int, current_day : int):
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		return
	
	var num_states = 5
	
	var growth_days_passed = (current_day - starting_day) % num_states
	var states_index = growth_days_passed % num_states + 1
	
	current_growth_state = states_index
	
	var name = DataTypes.GrowthStates.keys()[current_growth_state]
	print("Current Growth state: ", name, "Stat index: ", states_index)
	
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		crop_maturity.emit()

func harvest_state(starting_day: int, current_day : int) -> void:
	if current_growth_state == DataTypes.GrowthStates.Harvesting:
		return
	
	var days_passed = (current_day - starting_day) % days_until_harvest
	
	if days_passed == days_until_harvest - 1:
		current_growth_state = DataTypes.GrowthStates.Harvesting
		crop_harvesting.emit()

func get_current_growth_state() -> DataTypes.GrowthStates:
	return current_growth_state
