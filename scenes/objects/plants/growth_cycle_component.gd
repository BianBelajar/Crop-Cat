# =============================================================================
# growth_cycle_component.gd  —  VERSI DIPERBARUI
# Lokasi: res://scenes/objects/plants/growth_cycle_component.gd
#
# PERUBAHAN:
#   • days_unwatered → tanaman mati setelah 7 hari tidak disiram
#   • Pest TIDAK mematikan — hanya memperlambat pertumbuhan (increment 0.5)
#     sehingga tanaman butuh 2x lebih lama untuk hilang dibanding tanpa pest
#   • Sinyal plant_died hanya untuk kasus kekeringan
# =============================================================================
class_name GrowthCycleComponent
extends Node

@export var current_growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Germination
@export_range(5, 365) var days_until_harvest: int = 7

# ── Sinyal ────────────────────────────────────────────────────────────────────
signal crop_maturity
signal crop_harvesting
signal plant_died(cause: String)   # cause: "drought"

# ── State pertumbuhan ──────────────────────────────────────────────────────────
var is_watered: bool = false
var growth_points: float = 0.0
var starting_day: int
var current_day: int

# ── Penghitung kekeringan ──────────────────────────────────────────────────────
var days_unwatered: int = 0
const MAX_DAYS_UNWATERED: int = 7

func _ready() -> void:
	DayAndNightCycleManager.time_tick_day.connect(on_time_tick_day)

# =============================================================================
# TICK HARIAN UTAMA
# =============================================================================
func on_time_tick_day(_day: int) -> void:
	# ── 1. Cek kekeringan ──────────────────────────────────────────────────
	if is_watered:
		days_unwatered = 0
	else:
		days_unwatered += 1
		if days_unwatered >= MAX_DAYS_UNWATERED:
			_kill_plant("drought")
			return

	# ── 2. Pertumbuhan — pest memperlambat (0.5 poin/hari vs 1.0) ─────────
	if is_watered:
		var increment: float = 1.0
		if get_parent().has_pest:
			increment = 0.5   # Pest = 2x lebih lama tumbuh & menghilang

		growth_points += increment

		var effective_days: int = int(growth_points)
		growth_states_new_logic(effective_days)
		harvest_state_new_logic(effective_days)

# =============================================================================
# FUNGSI KEMATIAN (hanya kekeringan)
# =============================================================================
func _kill_plant(cause: String) -> void:
	plant_died.emit(cause)
	if get_parent().has_method("show_dead_sprite"):
		get_parent().show_dead_sprite()
	await get_tree().create_timer(1.5).timeout
	get_parent().queue_free()

# =============================================================================
# LOGIKA PERTUMBUHAN
# =============================================================================
func growth_states_new_logic(days_passed: int) -> void:
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		return
	var num_states: int = 5
	var states_index: int = (days_passed % num_states) + 1
	if states_index != current_growth_state:
		current_growth_state = states_index
		if current_growth_state == DataTypes.GrowthStates.Maturity:
			crop_maturity.emit()

func harvest_state_new_logic(days_passed: int) -> void:
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		if days_passed >= days_until_harvest:
			crop_harvesting.emit()

func get_current_growth_state() -> DataTypes.GrowthStates:
	return current_growth_state

# =============================================================================
# SAVE / LOAD
# =============================================================================
func get_save_data() -> Dictionary:
	return {
		"growth_points":  growth_points,
		"days_unwatered": days_unwatered,
		"growth_state":   int(current_growth_state),
		"is_watered":     is_watered,
	}

func apply_save_data(data: Dictionary) -> void:
	growth_points        = data.get("growth_points",  0.0)
	days_unwatered       = data.get("days_unwatered", 0)
	current_growth_state = data.get("growth_state",   DataTypes.GrowthStates.Germination)
	is_watered           = data.get("is_watered",     false)
