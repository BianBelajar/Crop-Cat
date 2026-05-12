# user_indicator_hud.gd — VERSI FINAL + FITUR ZOOM MINIMAP
# Lokasi: res://scenes/ui/user_indicator_hud.gd
#
# PERUBAHAN dari versi sebelumnya:
#   • Tambah sistem zoom minimap: tombol + dan - di bawah peta
#   • Zoom berubah bertahap lewat array ZOOM_STEPS
#   • ZoomLabel menampilkan persentase zoom saat ini
#   • Tombol + / - otomatis di-disable di batas min/max zoom
extends CanvasLayer


# ── Node References ───────────────────────────────────────────────────────────
@onready var label:              Label          = $MarginContainer/UserLabel
@onready var jurnal_button:      Button         = $JurnalButton
@onready var achievement_button: Button         = $AchievementButton

# Minimap (dengan null-check di _ready agar aman jika node tidak ada)
@onready var minimap_container:  PanelContainer = $MinimapContainer
@onready var minimap_viewport:   SubViewport    = $MinimapContainer/VBoxContainer/MinimapViewportContainer/MinimapViewport
@onready var minimap_camera:     Camera2D       = $MinimapContainer/VBoxContainer/MinimapViewportContainer/MinimapViewport/MinimapCamera

# Tombol Zoom (node baru)
@onready var zoom_in_button:  Button = $MinimapContainer/VBoxContainer/ZoomButtonsRow/ZoomInButton
@onready var zoom_out_button: Button = $MinimapContainer/VBoxContainer/ZoomButtonsRow/ZoomOutButton
@onready var zoom_label:      Label  = $MinimapContainer/VBoxContainer/ZoomButtonsRow/ZoomLabel


# ── Konfigurasi Zoom Minimap ──────────────────────────────────────────────────
#
# Setiap elemen adalah nilai camera.zoom langsung (Vector2 scalar).
# Indeks kecil = lebih jauh (zoom out), indeks besar = lebih dekat (zoom in).
#
#   0.08  → kamera zoom 0.08x → tampilkan area sangat luas  (12.5x dari default)
#   0.13  → kamera zoom 0.13x → zoom out sedang
#   0.25  → kamera zoom 0.25x → DEFAULT (sama dengan MINIMAP_ZOOM_LEVEL = 4.0)
#   0.40  → kamera zoom 0.40x → zoom in sedang
#   0.60  → kamera zoom 0.60x → zoom in maksimum (detail tinggi)
#
const ZOOM_STEPS:  Array[float]  = [0.08, 0.13, 0.25, 0.40, 0.60]
const ZOOM_LABELS: Array[String] = ["33%", "50%", "100%", "160%", "240%"]
const ZOOM_DEFAULT_INDEX: int    = 2   # index 2 = 0.25 = nilai default

var _zoom_index: int = ZOOM_DEFAULT_INDEX


# ── Achievement Menu ──────────────────────────────────────────────────────────
const ACHIEVEMENT_MENU_SCENE: String = "res://scenes/ui/achievement_menu.tscn"
var _achievement_menu_instance: CanvasLayer = null

# Tetap disimpan untuk kompatibilitas — tidak dipakai langsung setelah refactor zoom
const MINIMAP_ZOOM_LEVEL: float = 4.0
var _player: Node2D = null


# ── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	print("🛠️ UserIndicatorHUD: _ready() dimulai")

	# === HUD Label ===
	_update_label(SaveGameManager.current_username)
	SaveGameManager.user_changed.connect(_update_label)

	# === Jurnal Button ===
	jurnal_button.pressed.connect(_on_jurnal_pressed)
	QuestManager.quest_step_changed.connect(func(_s): _update_jurnal_button_visibility())
	QuestManager.quest_loaded_signal.connect(_update_jurnal_button_visibility)
	_update_jurnal_button_visibility()

	# === Achievement Button ===
	if achievement_button != null:
		achievement_button.pressed.connect(_on_achievement_button_pressed)
		print("🛠️ UserIndicatorHUD: Tombol achievement tersambung.")
	else:
		push_error("UserIndicatorHUD: $AchievementButton NULL! Cek scene.")

	# === Minimap + Zoom ===
	_setup_minimap()

	print("🛠️ UserIndicatorHUD: _ready() selesai tanpa error.")


# ── Achievement: buka/tutup menu ─────────────────────────────────────────────
func _on_achievement_button_pressed() -> void:
	print("🏆 Tombol Achievement ditekan!")
	if _achievement_menu_instance == null or not is_instance_valid(_achievement_menu_instance):
		var scene: PackedScene = load(ACHIEVEMENT_MENU_SCENE)
		_achievement_menu_instance = scene.instantiate()
		get_tree().root.add_child(_achievement_menu_instance)
		print("🏆 Achievement Menu dibuat dan ditambahkan ke scene.")

	if _achievement_menu_instance.visible:
		_achievement_menu_instance.hide_menu()
	else:
		_achievement_menu_instance.show_menu()


# ── Minimap Setup ─────────────────────────────────────────────────────────────
func _setup_minimap() -> void:
	if minimap_camera == null or minimap_viewport == null:
		push_warning("UserIndicatorHUD: Node minimap tidak ditemukan, minimap dilewati.")
		return

	# ── FIX BLUR: paksa Nearest-Neighbor filter untuk pixel art ──────────────
	var viewport_container: SubViewportContainer = minimap_viewport.get_parent()
	if viewport_container != null:
		viewport_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	minimap_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	# ── Terapkan zoom default ─────────────────────────────────────────────────
	_zoom_index = ZOOM_DEFAULT_INDEX
	_apply_zoom()

	# ── Bagikan World2D dengan scene utama ────────────────────────────────────
	minimap_viewport.world_2d = get_tree().root.world_2d

	# ── Sambungkan tombol zoom ────────────────────────────────────────────────
	if zoom_in_button != null and zoom_out_button != null:
		zoom_in_button.pressed.connect(_on_zoom_in_pressed)
		zoom_out_button.pressed.connect(_on_zoom_out_pressed)
		print("🗺️ Minimap: Tombol zoom tersambung.")
	else:
		push_warning("UserIndicatorHUD: Node ZoomInButton / ZoomOutButton tidak ditemukan. Pastikan sudah ditambahkan ke scene.")

	_refresh_player_reference()
	print("🗺️ Minimap setup selesai.")


# ── Zoom Logic ────────────────────────────────────────────────────────────────

## Terapkan nilai zoom dari array ZOOM_STEPS ke kamera minimap.
func _apply_zoom() -> void:
	if minimap_camera == null:
		return

	var zoom_value: float = ZOOM_STEPS[_zoom_index]
	minimap_camera.zoom = Vector2(zoom_value, zoom_value)

	# Update label teks
	if zoom_label != null:
		zoom_label.text = ZOOM_LABELS[_zoom_index]

	# Enable/disable tombol di batas
	if zoom_in_button != null:
		zoom_in_button.disabled = (_zoom_index >= ZOOM_STEPS.size() - 1)
	if zoom_out_button != null:
		zoom_out_button.disabled = (_zoom_index <= 0)

	print("🗺️ Minimap zoom → indeks %d | camera zoom %.2f | label %s" % [
		_zoom_index, zoom_value, ZOOM_LABELS[_zoom_index]
	])


## Tombol "+" ditekan → zoom in (tampilkan area lebih kecil, lebih detail).
func _on_zoom_in_pressed() -> void:
	if _zoom_index < ZOOM_STEPS.size() - 1:
		_zoom_index += 1
		_apply_zoom()


## Tombol "−" ditekan → zoom out (tampilkan area lebih luas).
func _on_zoom_out_pressed() -> void:
	if _zoom_index > 0:
		_zoom_index -= 1
		_apply_zoom()


# ── Player Reference ──────────────────────────────────────────────────────────
func _refresh_player_reference() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D
		return
	await get_tree().process_frame
	players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D


# ── Process: update kamera minimap ikuti pemain ───────────────────────────────
func _process(_delta: float) -> void:
	if not is_instance_valid(minimap_camera):
		return
	if is_instance_valid(_player):
		minimap_camera.global_position = _player.global_position
	elif _player == null:
		_refresh_player_reference()


# ── HUD Label ─────────────────────────────────────────────────────────────────
func _update_label(username: String) -> void:
	if username.is_empty():
		label.text = ""
		label.hide()
	else:
		label.text = "🌾 Login sebagai: " + username
		label.show()

func _on_jurnal_pressed() -> void:
	QuestManager.tampilkan_jurnal()

func _update_jurnal_button_visibility() -> void:
	jurnal_button.visible = QuestManager.quest_step >= 1 and not QuestManager.clue_quest_aktif.is_empty()
