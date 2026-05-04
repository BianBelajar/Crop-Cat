# =============================================================================
# education_manager.gd  —  AUTOLOAD BARU
# Lokasi: res://scripts/globals/education_manager.gd
#
# Cara daftarkan sebagai Autoload:
#   Project → Project Settings → Autoload → + → pilih file ini
#   Name: EducationManager
#
# FITUR:
#   • Melacak jenis tanaman yang sudah pernah ditanam (mencegah duplikat)
#   • Memicu pop-up edukasi saat tanaman baru pertama kali ditanam
#   • Memicu pop-up edukasi saat tanaman mati (kering / hama)
#   • State "tanaman sudah pernah dilihat" tersimpan dalam SaveGameManager
# =============================================================================
extends Node

# ── Referensi ke scene pop-up UI ────────────────────────────────────────────
const POPUP_SCENE: String = "res://scenes/ui/education_popup.tscn"

# ── Daftar tanaman yang SUDAH PERNAH ditanam (di-load dari save) ─────────────
var seen_plants: Dictionary = {}   # { "tomato": true, "wheat": true, ... }

# ── Database Fakta Pertanian ──────────────────────────────────────────────────
## Format: { "kunci_event": "Teks fakta yang akan ditampilkan" }
const FACTS: Dictionary = {
	# Pertama kali menanam
	"first_tomato": "🍅 Tahukah Kamu?\nTomat membutuhkan air secara rutin.\nKekeringan panjang dapat membunuh akarnya hingga ke tanah!",
	"first_wheat":  "🌾 Tahukah Kamu?\nGandum adalah salah satu tanaman tertua di dunia.\nIa sangat sensitif terhadap serangan kutu daun di fase muda!",

	# Mati karena kering
	"drought_tomato": "💧 Tanaman Mati Karena Kering!\nTomat tidak disiram selama 7 hari.\nAkar yang kering tidak bisa menyerap nutrisi dan tanaman pun layu selamanya.",
	"drought_wheat":  "💧 Tanaman Mati Karena Kering!\nGandum membutuhkan kelembapan tanah yang konsisten.\nJangan biarkan tanah retak karena kekeringan!",
	"drought_default":"💧 Tanaman Mati Karena Kering!\nSemua tanaman butuh air secara rutin.\nPastikan kamu menyiram setidaknya sekali sehari!",

	# Mati karena hama
	"pest_tomato":    "🐛 Tanaman Mati Karena Hama!\nKutu daun menyerap nutrisi tomat dengan sangat cepat.\nGunakan pestisida dalam 3 hari setelah hama terdeteksi!",
	"pest_wheat":     "🐛 Tanaman Mati Karena Hama!\nHama wereng bisa menghancurkan seluruh ladang gandum dalam 3 hari.\nWaspada dan semprotkan pestisida segera!",
	"pest_default":   "🐛 Tanaman Mati Karena Hama!\nHama yang dibiarkan selama 3 hari berturut-turut akan membunuh tanaman.\nGunakan Pestisida tepat waktu!",
}

# =============================================================================
# FUNGSI PUBLIK — dipanggil dari tomato.gd / wheat.gd
# =============================================================================

## Dipanggil saat tanaman baru di-spawn. Hanya tampilkan pop-up pertama kali.
func notify_first_plant(plant_type: String) -> void:
	if seen_plants.has(plant_type):
		return                              # Sudah pernah, lewati

	seen_plants[plant_type] = true
	var key: String = "first_" + plant_type
	_show_popup(FACTS.get(key, ""))

## Dipanggil dari on_plant_died di tomato.gd / wheat.gd.
## cause: "drought" atau "pest"
func notify_plant_death(plant_type: String, cause: String) -> void:
	var specific_key: String = cause + "_" + plant_type
	var fallback_key: String  = cause + "_default"
	var text: String = FACTS.get(specific_key, FACTS.get(fallback_key, ""))
	if not text.is_empty():
		_show_popup(text)

# =============================================================================
# PRIVATE — tampilkan pop-up
# =============================================================================
func _show_popup(fact_text: String) -> void:
	if fact_text.is_empty():
		return
	if not ResourceLoader.exists(POPUP_SCENE):
		push_warning("EducationManager: Scene pop-up tidak ditemukan di " + POPUP_SCENE)
		return

	var popup = load(POPUP_SCENE).instantiate()
	get_tree().root.add_child(popup)
	# Fungsi show_fact() akan kita buat di education_popup.gd
	popup.show_fact(fact_text)

# =============================================================================
# SAVE / LOAD — integrasi SaveGameManager
# =============================================================================

## Kembalikan data untuk disimpan (dipanggil dari SaveLevelDataComponent atau SaveGameManager).
func get_save_data() -> Dictionary:
	return {"seen_plants": seen_plants.duplicate()}

## Terapkan data yang dimuat dari save file.
func apply_save_data(data: Dictionary) -> void:
	seen_plants = data.get("seen_plants", {})
	print("[EducationManager] Data dimuat. Seen plants: ", seen_plants.keys())
