# user_indicator_hud.gd — VERSI FINAL DIPERBAIKI
# Lokasi: res://scenes/ui/user_indicator_hud.gd
#
# BUG KRITIS DITEMUKAN:
#   @onready var player_icon_overlay: TextureRect = $MinimapContainer/.../PlayerIconOverlay
#   Node "PlayerIconOverlay" TIDAK ADA di user_indicator_hud.tscn!
#   Akibatnya GDScript 4 langsung error saat _ready() dan menghentikan
#   eksekusi — termasuk baris achievement_button.pressed.connect(...).
#   Itulah kenapa tombol 🏆 tidak bisa diklik dan tidak ada yang berfungsi.
#
# FIX: Hapus @onready ke PlayerIconOverlay. Gunakan null-check untuk semua
#   minimap references agar aman walau node tidak ada.
extends CanvasLayer


# ── Node References ───────────────────────────────────────────────────────────
@onready var label:              Label          = $MarginContainer/UserLabel
@onready var jurnal_button:      Button         = $JurnalButton
@onready var achievement_button: Button         = $AchievementButton

# Minimap (dengan null-check di _ready agar aman jika node tidak ada)
@onready var minimap_container:  PanelContainer = $MinimapContainer
@onready var minimap_viewport:   SubViewport    = $MinimapContainer/VBoxContainer/MinimapViewportContainer/MinimapViewport
@onready var minimap_camera:     Camera2D       = $MinimapContainer/VBoxContainer/MinimapViewportContainer/MinimapViewport/MinimapCamera

# ── CATATAN: PlayerIconOverlay DIHAPUS karena tidak ada di .tscn ──────────────
# Jika kamu ingin menambahkannya, tambahkan TextureRect dengan nama
# "PlayerIconOverlay" sebagai child dari MinimapViewportContainer di scene,
# lalu uncomment baris di bawah ini:
# @onready var player_icon_overlay: TextureRect = $MinimapContainer/VBoxContainer/MinimapViewportContainer/PlayerIconOverlay


# ── Achievement Menu ──────────────────────────────────────────────────────────
const ACHIEVEMENT_MENU_SCENE: String = "res://scenes/ui/achievement_menu.tscn"
var _achievement_menu_instance: CanvasLayer = null

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

	# === Minimap ===
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


# ── Minimap ───────────────────────────────────────────────────────────────────
func _setup_minimap() -> void:
	if minimap_camera == null or minimap_viewport == null:
		push_warning("UserIndicatorHUD: Node minimap tidak ditemukan, minimap dilewati.")
		return
	minimap_camera.zoom = Vector2(1.0 / MINIMAP_ZOOM_LEVEL, 1.0 / MINIMAP_ZOOM_LEVEL)
	minimap_viewport.world_2d = get_tree().root.world_2d
	_refresh_player_reference()

func _refresh_player_reference() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D
		return
	await get_tree().process_frame
	players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D


# ── Process: update kamera minimap ───────────────────────────────────────────
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
