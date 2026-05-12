# achievement_notification.gd — VERSI FINAL DIPERBAIKI
# Lokasi: res://scenes/ui/achievement_notification.gd
#
# ROOT CAUSE BUG yang ditemukan:
#   Di versi sebelumnya, _move_panel_to_hidden() dipanggil DI DALAM _ready()
#   SEBELUM nilai _shown_offset_top disimpan. Akibatnya nilai yang tersimpan
#   adalah -100 (posisi tersembunyi), bukan 0 (posisi normal dari Inspector).
#   Sehingga animasi slide selalu bergerak dari -200 ke -100 (tidak terlihat).
#
# FIX: Gunakan nilai HARDCODED dari .tscn (offset_top=0, offset_bottom=84)
#   sehingga tidak bergantung pada urutan eksekusi _ready().
extends CanvasLayer


# ─── Node References ──────────────────────────────────────────────────────────
@onready var notif_panel:  PanelContainer = $NotifPanel
@onready var achiev_icon:  TextureRect    = $NotifPanel/MarginContainer/HBoxContainer/AchievIcon
@onready var top_label:    Label          = $NotifPanel/MarginContainer/HBoxContainer/VBoxContainer/TopLabel
@onready var title_label:  Label          = $NotifPanel/MarginContainer/HBoxContainer/VBoxContainer/TitleLabel


# ─── Konstanta posisi (dari achievement_notification.tscn) ───────────────────
# Panel pakai anchors_preset=5 (PRESET_CENTER_TOP), offset_top=0, offset_bottom=84
const PANEL_SHOWN_TOP:    float = 0.0
const PANEL_SHOWN_BOTTOM: float = 84.0
const PANEL_HIDDEN_TOP:    float = -100.0
const PANEL_HIDDEN_BOTTOM: float = -16.0  # -100 + 84

const SLIDE_DURATION: float = 0.4
const HOLD_DURATION:  float = 3.0


# ─── State antrian ────────────────────────────────────────────────────────────
var _queue: Array[Dictionary] = []
var _is_animating: bool = false


# ─── READY ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("🛠️ AchievementNotification: _ready() dipanggil")

	if notif_panel == null:
		push_error("AchievementNotification: $NotifPanel NULL!")
		return

	# Sembunyikan panel di atas layar
	notif_panel.offset_top    = PANEL_HIDDEN_TOP
	notif_panel.offset_bottom = PANEL_HIDDEN_BOTTOM
	notif_panel.visible = false

	# Connect sinyal
	if not AchievementManager.achievement_unlocked.is_connected(_on_achievement_unlocked):
		AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)
		print("🛠️ AchievementNotification: Sinyal achievement_unlocked TERSAMBUNG.")


# ─── Callback sinyal dari AchievementManager ─────────────────────────────────
func _on_achievement_unlocked(id: String, data: Dictionary) -> void:
	print("🔔 UI Notifikasi menerima sinyal dan mulai animasi — '", data.get("title","?"), "'")
	_queue.append(data)
	if not _is_animating:
		_show_next_in_queue()


# ─── Antrian ──────────────────────────────────────────────────────────────────
func _show_next_in_queue() -> void:
	if _queue.is_empty():
		_is_animating = false
		return
	_is_animating = true
	var data: Dictionary = _queue.pop_front()
	await _animate_notification(data)
	_show_next_in_queue()


# ─── Animasi ──────────────────────────────────────────────────────────────────
func _animate_notification(data: Dictionary) -> void:
	if notif_panel == null:
		return

	title_label.text = data.get("title", "Achievement")
	top_label.text   = "✨ Pencapaian Terbuka!"

	var icon_path: String = data.get("unlocked_icon", "")
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		achiev_icon.texture = load(icon_path)
	else:
		achiev_icon.texture = null

	# Reset ke posisi tersembunyi lalu tampilkan
	notif_panel.offset_top    = PANEL_HIDDEN_TOP
	notif_panel.offset_bottom = PANEL_HIDDEN_BOTTOM
	notif_panel.visible = true

	# Slide turun masuk
	var tw_in := create_tween()
	tw_in.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw_in.tween_property(notif_panel, "offset_top",    PANEL_SHOWN_TOP,    SLIDE_DURATION).from(PANEL_HIDDEN_TOP)
	tw_in.parallel().tween_property(notif_panel, "offset_bottom", PANEL_SHOWN_BOTTOM, SLIDE_DURATION).from(PANEL_HIDDEN_BOTTOM)
	await tw_in.finished

	print("🔔 Panel terlihat — tahan ", HOLD_DURATION, "s")
	await get_tree().create_timer(HOLD_DURATION).timeout

	# Slide naik keluar
	var tw_out := create_tween()
	tw_out.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw_out.tween_property(notif_panel, "offset_top",    PANEL_HIDDEN_TOP,    SLIDE_DURATION)
	tw_out.parallel().tween_property(notif_panel, "offset_bottom", PANEL_HIDDEN_BOTTOM, SLIDE_DURATION)
	await tw_out.finished

	notif_panel.visible = false
	print("🔔 Animasi notifikasi selesai.")
