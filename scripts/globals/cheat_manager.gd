# =============================================================================
# cheat_manager.gd  —  Sistem Cheat/Admin untuk Skip Quest
# Lokasi: res://scripts/globals/cheat_manager.gd
#
# Daftarkan sebagai AUTOLOAD di Project Settings dengan nama: CheatManager
# =============================================================================
extends Node

# Panel cheat (akan diisi saat _ready)
var cheat_panel: Control = null
var is_panel_visible: bool = false

# Semua item yang dibutuhkan untuk setiap stage quest
const ITEMS_PER_STAGE: Dictionary = {
	1: {"log": 10},                                                           # Quest 1: Kayu untuk Mbah Kucing
	2: {"log": 10, "stone": 5},                                               # Quest 2: Batu
	3: {"log": 10, "stone": 5},                                               # Quest 3: Beri makan hewan
	4: {"log": 10, "stone": 5},                                               # Quest 4: Dapat farming kit
	5: {"egg": 3, "milk": 3, "log": 10, "stone": 5},                         # Quest 5: Tukar pestisida
	6: {"egg": 3, "milk": 3, "log": 10, "stone": 5},                         # Quest 6: Dapat pestisida
	7: {"log": 15, "stone": 10, "tomato": 20, "wheat": 20, "milk": 10, "egg": 10},  # Quest 7: Mulai repair kapal
	8: {"log": 15, "stone": 10, "tomato": 20, "wheat": 20, "milk": 10, "egg": 10},  # Quest 8: Kumpulkan bahan
	9: {"log": 15, "stone": 10, "tomato": 20, "wheat": 20, "milk": 10, "egg": 10},  # Quest 9: Serahkan bahan
}

func _ready() -> void:
	# Buat panel cheat secara programatik
	_build_cheat_panel()
	print("[CheatManager] Siap. Tekan Ctrl+Shift+D untuk membuka panel cheat.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_cheat"):
		_toggle_panel()
		get_viewport().set_input_as_handled()

# =============================================================================
# PANEL BUILDER
# =============================================================================

func _build_cheat_panel() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 128
	canvas.name = "CheatCanvasLayer"
	get_tree().root.call_deferred("add_child", canvas)

	# ✅ Panel lebih kecil dan posisi lebih aman (tidak kepotong kanan)
	var panel = PanelContainer.new()
	panel.name = "CheatPanel"
	panel.visible = false
	# Anchor ke top-right, dengan offset agar tidak kepotong
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -230   # lebar panel
	panel.offset_top  = 8
	panel.offset_right = -8    # jarak dari tepi kanan
	panel.offset_bottom = 500  # tinggi maksimal panel
	canvas.call_deferred("add_child", panel)
	cheat_panel = panel

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	panel.add_child(margin)

	var vbox_outer = VBoxContainer.new()
	margin.add_child(vbox_outer)

	# Judul
	var title = Label.new()
	title.text = "🐾 CHEAT  [Ctrl+Shift+D]"
	title.add_theme_color_override("font_color", Color.YELLOW)
	title.add_theme_font_size_override("font_size", 11)
	vbox_outer.add_child(title)

	vbox_outer.add_child(HSeparator.new())

	# ✅ ScrollContainer agar tombol tidak kepotong layar
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(200, 380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox_outer.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	scroll.add_child(vbox)

	# ── Skip Quest ──────────────────────────────────────────────
	_add_small_label(vbox, "— SKIP QUEST —")
	_add_small_button(vbox, "Step 1: Kapak",         func(): _jump_to_quest(1))
	_add_small_button(vbox, "Step 2: Batu",           func(): _jump_to_quest(2))
	_add_small_button(vbox, "Step 3: Hewan",          func(): _jump_to_quest(3))
	_add_small_button(vbox, "Step 4: Farming Kit",    func(): _jump_to_quest(4))
	_add_small_button(vbox, "Step 5: Pestisida",      func(): _jump_to_quest(5))
	_add_small_button(vbox, "Step 6: Aktif Pestisida",func(): _jump_to_quest(6))
	_add_small_button(vbox, "Step 7: Repair Kapal",   func(): _jump_to_quest(7))
	_add_small_button(vbox, "Step 8: Bahan Kapal",    func(): _jump_to_quest(8))

	vbox.add_child(HSeparator.new())

	# ── Item ────────────────────────────────────────────────────
	_add_small_label(vbox, "— ITEM —")
	_add_small_button(vbox, "Auto-Fill Semua Item",   func(): _fill_all_items())
	_add_small_button(vbox, "+20 Kayu",               func(): _add_items({"log": 20}))
	_add_small_button(vbox, "+15 Batu",               func(): _add_items({"stone": 15}))
	_add_small_button(vbox, "+25 Gandum & Tomat",     func(): _add_items({"wheat": 25, "tomato": 25}))
	_add_small_button(vbox, "+15 Telur & Susu",       func(): _add_items({"egg": 15, "milk": 15}))

	vbox.add_child(HSeparator.new())

	# ── Ending & Reset ──────────────────────────────────────────
	_add_small_button(vbox, "🎬 Trigger Ending", func(): _trigger_ending_directly(), Color.ORANGE_RED)
	_add_small_button(vbox, "🔄 Reset Quest",    func(): _reset_quest(), Color.CORNFLOWER_BLUE)

# ── Helper: label section kecil ─────────────────────────────────────────────
func _add_small_label(parent: VBoxContainer, text: String) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	parent.add_child(lbl)

# ── Helper: tombol compact ───────────────────────────────────────────────────
func _add_small_button(parent: VBoxContainer, text: String, callback: Callable, color: Color = Color.WHITE) -> void:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", color)
	btn.custom_minimum_size = Vector2(0, 22)   # ✅ tinggi tombol diperkecil
	btn.pressed.connect(callback)
	parent.add_child(btn)

# =============================================================================
# AKSI CHEAT
# =============================================================================

## Loncat langsung ke quest step tertentu dan isi inventory yang dibutuhkan.
func _jump_to_quest(step: int) -> void:
	# Set quest step
	QuestManager.quest_step = step
	QuestManager.is_intro_done = true

	# Aktifkan semua tool sesuai quest step (sync dengan tools_panel.gd)
	_sync_tools_for_step(step)

	# Isi item yang relevan untuk step ini
	if ITEMS_PER_STAGE.has(step):
		_add_items(ITEMS_PER_STAGE[step])

	# Simpan otomatis
	SaveGameManager.save_game()

	print("[CheatManager] ✅ Quest di-skip ke step %d" % step)
	_show_notification("Quest di-skip ke Step %d!" % step)

## Isi semua item yang diperlukan untuk repair kapal (kondisi quest terakhir).
func _fill_all_items() -> void:
	_add_items({
		"log": 20,
		"stone": 15,
		"tomato": 25,
		"wheat": 25,
		"milk": 15,
		"egg": 15,
	})
	print("[CheatManager] ✅ Semua item quest sudah diisi!")
	_show_notification("Semua item terisi!")

## Tambahkan item ke inventory.
func _add_items(items: Dictionary) -> void:
	for item_name in items:
		var amount = items[item_name]
		for i in range(amount):
			InventoryManager.add_collectable(item_name)

## Aktifkan semua tool sesuai quest step saat ini.
func _sync_tools_for_step(step: int) -> void:
	if step >= 1:
		ToolManager.enable_tool_button(DataTypes.Tools.AxeWood)
	if step >= 4:
		ToolManager.enable_tool_button(DataTypes.Tools.TillGround)
		ToolManager.enable_tool_button(DataTypes.Tools.WaterCrops)
		ToolManager.enable_tool_button(DataTypes.Tools.PlantWheat)
		ToolManager.enable_tool_button(DataTypes.Tools.PlantTomato)
	if step >= 6:
		ToolManager.enable_tool_button(DataTypes.Tools.Pesticide)

## Trigger ending langsung tanpa harus bicara ke Mbah Kucing.
func _trigger_ending_directly() -> void:
	# Isi semua item dulu agar logic check terpenuhi
	_fill_all_items()
	QuestManager.quest_step = 9
	SaveGameManager.save_game()
	# Emit sinyal agar guide.gd memuat ending cutscene
	GameDialogueManager.trigger_ending.emit()
	print("[CheatManager] 🎬 Ending dipicu langsung!")

## Reset quest ke awal.
func _reset_quest() -> void:
	QuestManager.quest_step = 0
	QuestManager.is_intro_done = false
	SaveGameManager.save_game()
	print("[CheatManager] 🔄 Quest di-reset ke step 0")
	_show_notification("Quest di-reset!")

# =============================================================================
# PANEL TOGGLE & NOTIFIKASI
# =============================================================================

func _toggle_panel() -> void:
	if cheat_panel == null:
		return
	is_panel_visible = !is_panel_visible
	cheat_panel.visible = is_panel_visible

## Tampilkan notifikasi singkat di layar.
func _show_notification(message: String) -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 129
	get_tree().root.add_child(canvas)

	var label = Label.new()
	label.text = "✅ " + message
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	label.position = Vector2(20, 20)
	canvas.add_child(label)

	# Hilangkan notifikasi setelah 2 detik
	await get_tree().create_timer(2.0).timeout
	canvas.queue_free()
