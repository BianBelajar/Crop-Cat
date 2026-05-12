# user_indicator_hud.gd  [VERSI SUDAH DIPERBAIKI - TUGAS 2]
extends CanvasLayer

# ── Node References (yang sudah ada) ─────────────────────────────────────────
@onready var label: Label          = $MarginContainer/UserLabel
@onready var jurnal_button: Button = $JurnalButton

# ── Node References Minimap ───────────────────────────────────────────────────
@onready var minimap_container: PanelContainer = $MinimapContainer
@onready var minimap_viewport: SubViewport     = $MinimapContainer/VBoxContainer/MinimapViewportContainer/MinimapViewport
@onready var minimap_camera: Camera2D          = $MinimapContainer/VBoxContainer/MinimapViewportContainer/MinimapViewport/MinimapCamera

# ── TAMBAHKAN: Referensi tombol dan menu achievement ─────────────────────────
@onready var achievement_button: Button = $AchievementButton  # ← TAMBAHKAN

const ACHIEVEMENT_MENU_SCENE: String = "res://scenes/ui/achievement_menu.tscn"
var _achievement_menu_instance: CanvasLayer = null  # ← TAMBAHKAN
# ✨ TAMBAHAN BARU (TUGAS 2): Referensi ikon overlay player di tengah minimap.
# Node ini adalah TextureRect yang diletakkan SEBAGAI SIBLING dari MinimapViewport
# di dalam MinimapViewportContainer, bukan di dalam SubViewport.
# Posisinya: di tengah MinimapViewportContainer, di atas render viewport.
@onready var player_icon_overlay: TextureRect = $MinimapContainer/VBoxContainer/MinimapViewportContainer/PlayerIconOverlay

const MINIMAP_ZOOM_LEVEL: float = 4.0
var _player: Node2D = null

# ── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# === Kode HUD asli (tidak diubah) ===
	_update_label(SaveGameManager.current_username)
	SaveGameManager.user_changed.connect(_update_label)
	jurnal_button.pressed.connect(_on_jurnal_pressed)
	QuestManager.quest_step_changed.connect(func(_s): _update_jurnal_button_visibility())
	QuestManager.quest_loaded_signal.connect(_update_jurnal_button_visibility)
	_update_jurnal_button_visibility()

	# === TAMBAHKAN: Setup tombol achievement ===
	achievement_button.pressed.connect(_on_achievement_button_pressed)  # ← TAMBAHKAN
	# === Setup Minimap ===
	_setup_minimap()

# ── TAMBAHKAN: Fungsi buka/tutup menu achievement ────────────────────────────
func _on_achievement_button_pressed() -> void:
	# Jika instance belum ada, buat dari scene
	if _achievement_menu_instance == null:
		var scene: PackedScene = load(ACHIEVEMENT_MENU_SCENE)
		_achievement_menu_instance = scene.instantiate()
		# Tambahkan ke root agar berada di layer tertinggi
		get_tree().root.add_child(_achievement_menu_instance)

	# Toggle: jika sudah terlihat → tutup, jika tersembunyi → buka
	if _achievement_menu_instance.visible:
		_achievement_menu_instance.hide_menu()
	else:
		_achievement_menu_instance.show_menu()
# ── SELESAI TAMBAHAN ──────────────────────────────────────────────────────────

func _setup_minimap() -> void:
	# Set zoom kamera minimap
	minimap_camera.zoom = Vector2(
		1.0 / MINIMAP_ZOOM_LEVEL,
		1.0 / MINIMAP_ZOOM_LEVEL
	)

	# Share world_2d agar SubViewport bisa melihat dunia game
	# (Tanpa baris ini, minimap akan selalu hitam kosong)
	minimap_viewport.world_2d = get_tree().root.world_2d

	# Cari player lewat group
	_refresh_player_reference()

func _refresh_player_reference() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D
		return

	# Jika belum ada, tunggu 1 frame dan coba lagi sekali
	await get_tree().process_frame
	players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D

# ── PROCESS ───────────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	# Guard null check agar tidak error setiap frame
	if not is_instance_valid(minimap_camera):
		return
	if is_instance_valid(_player):
		minimap_camera.global_position = _player.global_position
	elif _player == null:
		# Player belum ditemukan, coba cari lagi (hanya jika benar-benar null)
		_refresh_player_reference()

# ── Fungsi HUD asli (tidak diubah) ───────────────────────────────────────────
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
