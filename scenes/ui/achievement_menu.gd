# achievement_menu.gd
extends CanvasLayer

# ─── Node References ──────────────────────────────────────────────────────────
@onready var grid_container: GridContainer = $PanelContainer/MarginContainer/ScrollContainer/GridContainer
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton


# Path ke theme (untuk di-assign ke card yang dibuat secara dinamis)
const THEME_PATH: String = "res://game_ui_theme.tres"
const FONT_PATH: String  = "res://assets/ui/fonts/zx_palm_variation.tres"


# ─── READY ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	close_button.pressed.connect(hide_menu)
	# Refresh tampilan setiap kali ada achievement baru yang terbuka
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)


# ─── TAMPILKAN MENU ───────────────────────────────────────────────────────────
func show_menu() -> void:
	_populate_grid()
	visible = true
	# Pause game opsional saat menu terbuka
	get_tree().paused = true


func hide_menu() -> void:
	visible = false
	get_tree().paused = false


# ─── BANGUN ISI GRID ──────────────────────────────────────────────────────────
func _populate_grid() -> void:
	# Hapus semua card lama sebelum mengisi ulang
	for child in grid_container.get_children():
		child.queue_free()

	# Loop semua achievement dari AchievementManager
	for id in AchievementManager.achievements:
		var data: Dictionary = AchievementManager.achievements[id]
		var card := _create_achievement_card(data)
		grid_container.add_child(card)


## Membuat satu "kartu" achievement berdasarkan datanya.
func _create_achievement_card(data: Dictionary) -> Control:
	var theme_res: Theme = load(THEME_PATH)
	var font_res: FontVariation = load(FONT_PATH)

	# === Container Kartu ===
	var panel := PanelContainer.new()
	panel.theme = theme_res
	panel.theme_type_variation = &"DarkWoodPanel"
	panel.custom_minimum_size = Vector2(140, 60)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	margin.add_child(hbox)

	# === Ikon ===
	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(32, 32)
	icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# ── LOGIKA VISUAL UTAMA ──
	if data["is_unlocked"]:
		# Achievement terbuka: tampilkan ikon asli, nama dan deskripsi asli
		if ResourceLoader.exists(data["unlocked_icon"]):
			icon_rect.texture = load(data["unlocked_icon"])
	else:
		# Achievement terkunci: tampilkan ikon gembok
		if ResourceLoader.exists(data["locked_icon"]):
			icon_rect.texture = load(data["locked_icon"])
	hbox.add_child(icon_rect)

	# === Teks ===
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var title_label := Label.new()
	title_label.theme = theme_res
	title_label.add_theme_font_override("font", font_res)
	title_label.add_theme_font_size_override("font_size", 8)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var desc_label := Label.new()
	desc_label.theme = theme_res
	desc_label.add_theme_font_override("font", font_res)
	desc_label.add_theme_font_size_override("font_size", 7)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.modulate = Color(0.8, 0.8, 0.8, 1.0)

	if data["is_unlocked"]:
		title_label.text = data["title"]
		desc_label.text  = data["description"]
	else:
		title_label.text = "???"
		desc_label.text  = "Selesaikan tantangan untuk membuka ini."

	vbox.add_child(title_label)
	vbox.add_child(desc_label)

	return panel


# ─── Callback saat achievement baru terbuka (refresh grid jika menu terbuka) ──
func _on_achievement_unlocked(_id: String, _data: Dictionary) -> void:
	if visible:
		_populate_grid()
