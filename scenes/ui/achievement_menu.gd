# achievement_menu.gd — FULL REWRITE
# Seluruh UI dibangun dari kode. Scene hanya butuh 1 node: CanvasLayer (root).
# Tidak ada @onready, tidak ada ketergantungan nama node di scene.
extends CanvasLayer

# ── Konstanta ─────────────────────────────────────────────────────────────────
const THEME_PATH : String = "res://game_ui_theme.tres"
const FONT_PATH  : String = "res://assets/ui/fonts/zx_palm_variation.tres"
const ICON_SIZE  : float  = 32.0

# ── Referensi node (dibuat di _ready) ─────────────────────────────────────────
var _panel       : PanelContainer
var _grid        : GridContainer
var _close_btn   : Button
var _scroll      : ScrollContainer


# ── READY: bangun semua UI dari kode ──────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer   = 15
	visible = false

	var theme_res : Theme         = load(THEME_PATH)
	var font_res  : FontVariation = load(FONT_PATH)

	# ── 1. Panel utama (tengah layar) ─────────────────────────────────────────
	_panel = PanelContainer.new()
	_panel.theme                = theme_res
	_panel.theme_type_variation = &"DarkWoodPanel"
	# Anchor ke tengah layar
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical   = Control.GROW_DIRECTION_BOTH
	_panel.offset_left     = -155.0
	_panel.offset_right    =  155.0
	_panel.offset_top      = -120.0
	_panel.offset_bottom   =  120.0
	add_child(_panel)

	# ── 2. Margin luar ────────────────────────────────────────────────────────
	var outer_margin := MarginContainer.new()
	outer_margin.add_theme_constant_override("margin_left",   8)
	outer_margin.add_theme_constant_override("margin_right",  8)
	outer_margin.add_theme_constant_override("margin_top",    6)
	outer_margin.add_theme_constant_override("margin_bottom", 6)
	_panel.add_child(outer_margin)

	# ── 3. VBox utama ─────────────────────────────────────────────────────────
	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 6)
	outer_margin.add_child(root_vbox)

	# ── 4. Header (judul + tombol X) ──────────────────────────────────────────
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	# Header TIDAK boleh expand — tinggi tetap
	header.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	root_vbox.add_child(header)

	var title_lbl := Label.new()
	title_lbl.text                   = "Pencapaian"
	title_lbl.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	title_lbl.size_flags_vertical    = Control.SIZE_SHRINK_CENTER
	title_lbl.add_theme_font_override("font", font_res)
	title_lbl.add_theme_font_size_override("font_size", 10)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.5))
	header.add_child(title_lbl)

	_close_btn = Button.new()
	_close_btn.text                  = "X"
	_close_btn.theme                 = theme_res
	_close_btn.theme_type_variation  = &"ToolButton"
	_close_btn.custom_minimum_size   = Vector2(22, 22)
	_close_btn.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	_close_btn.pressed.connect(hide_menu)
	header.add_child(_close_btn)

	# ── 5. Separator tipis ────────────────────────────────────────────────────
	var sep := HSeparator.new()
	sep.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	root_vbox.add_child(sep)

	# ── 6. ScrollContainer — harus EXPAND agar mengisi sisa ruang ────────────
	_scroll = ScrollContainer.new()
	_scroll.size_flags_horizontal        = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical          = Control.SIZE_EXPAND_FILL  # ← kunci scroll
	_scroll.horizontal_scroll_mode       = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode         = ScrollContainer.SCROLL_MODE_AUTO
	root_vbox.add_child(_scroll)

	# ── 7. GridContainer di dalam scroll ──────────────────────────────────────
	_grid = GridContainer.new()
	_grid.columns                  = 2
	_grid.size_flags_horizontal    = Control.SIZE_EXPAND_FILL
	# JANGAN set SIZE_EXPAND_FILL vertikal — biarkan grid tumbuh alami ke bawah
	_grid.size_flags_vertical      = Control.SIZE_SHRINK_BEGIN
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_scroll.add_child(_grid)

	# ── 8. Dengarkan sinyal achievement ───────────────────────────────────────
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)
	set_process_unhandled_key_input(true)


# ── Input: tutup dengan Escape ────────────────────────────────────────────────
func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_menu()


# ── Buka menu ─────────────────────────────────────────────────────────────────
func show_menu() -> void:
	_populate_grid()
	visible = true
	get_tree().paused = true


# ── Tutup menu ────────────────────────────────────────────────────────────────
func hide_menu() -> void:
	visible = false
	get_tree().paused = false


# ── Isi grid dengan kartu achievement ─────────────────────────────────────────
func _populate_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()
	# Tunggu 1 frame agar queue_free selesai sebelum menambah anak baru
	await get_tree().process_frame
	for id in AchievementManager.achievements:
		_grid.add_child(_create_card(AchievementManager.achievements[id]))


# ── Buat satu kartu ───────────────────────────────────────────────────────────
func _create_card(data: Dictionary) -> Control:
	var theme_res  : Theme         = load(THEME_PATH)
	var font_res   : FontVariation = load(FONT_PATH)
	var is_unlocked: bool          = data["is_unlocked"]

	# Panel kartu
	var panel := PanelContainer.new()
	panel.theme                 = theme_res
	panel.theme_type_variation  = &"DarkWoodPanel"
	panel.custom_minimum_size   = Vector2(130.0, 54.0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   5)
	margin.add_theme_constant_override("margin_right",  5)
	margin.add_theme_constant_override("margin_top",    5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	margin.add_child(hbox)

	# ── Ikon: hanya tampil jika sudah unlock ──────────────────────────────────
	if is_unlocked:
		var icon_wrap := Control.new()
		icon_wrap.custom_minimum_size   = Vector2(ICON_SIZE, ICON_SIZE)
		icon_wrap.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		icon_wrap.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		hbox.add_child(icon_wrap)

		var icon_rect := TextureRect.new()
		icon_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_rect.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists(data["unlocked_icon"]):
			icon_rect.texture = load(data["unlocked_icon"])
		icon_wrap.add_child(icon_rect)
	else:
		# Jika terkunci: placeholder abu-abu kecil (tanda tanya)
		var placeholder := Label.new()
		placeholder.text                  = "?"
		placeholder.custom_minimum_size   = Vector2(ICON_SIZE, ICON_SIZE)
		placeholder.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
		placeholder.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		placeholder.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		placeholder.add_theme_font_override("font", font_res)
		placeholder.add_theme_font_size_override("font_size", 16)
		placeholder.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		hbox.add_child(placeholder)

	# ── Teks ──────────────────────────────────────────────────────────────────
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)

	# Judul
	var title_lbl := Label.new()
	title_lbl.add_theme_font_override("font", font_res)
	title_lbl.add_theme_font_size_override("font_size", 8)
	title_lbl.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.text = data["title"] if is_unlocked else "???"
	title_lbl.add_theme_color_override(
		"font_color",
		Color(1.0, 0.95, 0.5) if is_unlocked else Color(0.55, 0.55, 0.55)
	)
	vbox.add_child(title_lbl)

	# Deskripsi (selalu tampil sebagai clue)
	var desc_lbl := Label.new()
	desc_lbl.add_theme_font_override("font", font_res)
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_lbl.text = data["description"]
	desc_lbl.add_theme_color_override(
		"font_color",
		Color(0.85, 0.85, 0.85) if is_unlocked else Color(0.45, 0.45, 0.45)
	)
	vbox.add_child(desc_lbl)

	return panel


# ── Refresh grid saat achievement baru terbuka ────────────────────────────────
func _on_achievement_unlocked(_id: String, _data: Dictionary) -> void:
	if visible:
		_populate_grid()
