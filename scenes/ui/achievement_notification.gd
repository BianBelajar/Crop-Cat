# achievement_notification.gd
extends CanvasLayer

# ─── Node References ──────────────────────────────────────────────────────────
@onready var notif_panel:  PanelContainer = $NotifPanel
@onready var achiev_icon:  TextureRect    = $NotifPanel/MarginContainer/HBoxContainer/AchievIcon
@onready var top_label:    Label          = $NotifPanel/MarginContainer/HBoxContainer/VBoxContainer/TopLabel
@onready var title_label:  Label          = $NotifPanel/MarginContainer/HBoxContainer/VBoxContainer/TitleLabel

# ─── Konstanta Animasi ────────────────────────────────────────────────────────
## Durasi animasi slide masuk/keluar (detik)
const SLIDE_DURATION:  float = 0.4
## Durasi panel terlihat di layar (detik)
const HOLD_DURATION:   float = 3.0
## Posisi Y saat tersembunyi (di atas layar, negatif)
const HIDDEN_Y_OFFSET: float = -100.0

# ─── State ────────────────────────────────────────────────────────────────────
## Antrian notifikasi jika achievement unlock berurutan cepat
var _queue: Array[Dictionary] = []
var _is_animating: bool = false


# ─── READY ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Sembunyikan panel di atas layar saat awal
	_move_panel_to_hidden()
	notif_panel.visible = false

	# Dengarkan sinyal dari AchievementManager
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)


# ─── Callback Sinyal ──────────────────────────────────────────────────────────
func _on_achievement_unlocked(id: String, data: Dictionary) -> void:
	# Masukkan ke antrian
	_queue.append(data)
	# Jika tidak sedang animasi, langsung tampilkan
	if not _is_animating:
		_show_next_in_queue()


# ─── Ambil item berikutnya dari antrian ───────────────────────────────────────
func _show_next_in_queue() -> void:
	if _queue.is_empty():
		_is_animating = false
		return

	_is_animating = true
	var data: Dictionary = _queue.pop_front()
	await _animate_notification(data)
	# Setelah animasi selesai, cek antrian lagi
	_show_next_in_queue()


# ─── ANIMASI UTAMA ────────────────────────────────────────────────────────────
func _animate_notification(data: Dictionary) -> void:
	# --- Isi data ---
	title_label.text = data["title"]
	top_label.text   = "✨ Pencapaian Terbuka!"

	if ResourceLoader.exists(data["unlocked_icon"]):
		achiev_icon.texture = load(data["unlocked_icon"])
	else:
		achiev_icon.texture = null

	# --- Posisi awal: tersembunyi di atas ---
	_move_panel_to_hidden()
	notif_panel.visible = true

	# Hitung posisi Y "terlihat" (posisi normal berdasarkan anchor)
	# Karena kita pakai anchor top-right, Y offset dari anchor sudah di-set di inspector.
	# Kita gerakkan posisi ke bawah secara relatif.
	var shown_y: float = notif_panel.offset_top  # Posisi Y yang seharusnya (dari inspector)
	var hidden_y: float = shown_y + HIDDEN_Y_OFFSET

	# --- TWEEN: Slide turun masuk ---
	var tween_in := create_tween()
	tween_in.set_ease(Tween.EASE_OUT)
	tween_in.set_trans(Tween.TRANS_BACK)
	tween_in.tween_property(
		notif_panel,
		"offset_top",
		shown_y,        # target: posisi terlihat
		SLIDE_DURATION
	).from(hidden_y)   # dari: posisi tersembunyi di atas
	# Sync offset_bottom juga agar ukuran panel tidak berubah
	var panel_height: float = notif_panel.offset_bottom - notif_panel.offset_top
	tween_in.parallel().tween_property(
		notif_panel,
		"offset_bottom",
		shown_y + panel_height,
		SLIDE_DURATION
	).from(hidden_y + panel_height)

	await tween_in.finished

	# --- Tahan selama HOLD_DURATION ---
	await get_tree().create_timer(HOLD_DURATION).timeout

	# --- TWEEN: Slide naik keluar ---
	var tween_out := create_tween()
	tween_out.set_ease(Tween.EASE_IN)
	tween_out.set_trans(Tween.TRANS_CUBIC)
	tween_out.tween_property(
		notif_panel,
		"offset_top",
		hidden_y,       # target: naik ke atas layar
		SLIDE_DURATION
	)
	tween_out.parallel().tween_property(
		notif_panel,
		"offset_bottom",
		hidden_y + panel_height,
		SLIDE_DURATION
	)

	await tween_out.finished

	notif_panel.visible = false
	# Reset ke posisi tersembunyi untuk notif berikutnya
	_move_panel_to_hidden()


# ─── Helper: Pindahkan panel ke posisi tersembunyi ───────────────────────────
func _move_panel_to_hidden() -> void:
	# Geser panel ke atas layar sebesar HIDDEN_Y_OFFSET
	# Nilai default dari inspector adalah offset_top = 10, offset_bottom = 70
	# Kita geser ke negatif agar keluar dari layar atas
	notif_panel.offset_top    = HIDDEN_Y_OFFSET
	notif_panel.offset_bottom = HIDDEN_Y_OFFSET + 60.0
