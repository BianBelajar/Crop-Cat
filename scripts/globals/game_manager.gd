## game_manager.gd  (PATCH — ganti bagian preload & show_game_menu_screen)
## Autoload — tidak ada perubahan besar, hanya referensi scene diperbarui.
##
## Perubahan dari versi lama:
##   • game_menu_screen  → sekarang mengarah ke main_menu.tscn
##   • show_game_menu_screen() → show_main_menu()  (alias tetap ada)

extends Node

# ── Referensi scene yang baru ────────────────────────────────────────────────
var main_menu_scene : PackedScene = preload("res://scenes/ui/game_menu_screen.tscn")

# ── Shortcut keyboard untuk membuka pause menu (saat game berjalan) ──────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		# Saat game sedang berjalan → tampilkan Pause Menu, bukan Main Menu
		if SaveGameManager.allow_save_game:
			show_pause_menu()
		else:
			show_main_menu()

func show_login_screen() -> void:
	var login_scene: PackedScene = preload("res://scenes/ui/login_screen.tscn")
	var instance: Node = login_scene.instantiate()
	get_tree().root.add_child(instance)

# ─────────────────────────────────────────────
# GAME FLOW  (tidak berubah)
# ─────────────────────────────────────────────

func start_game() -> void:
	assert(
		not SaveGameManager.current_username.is_empty(),
		"GameManager.start_game(): User harus login dulu!"
	)
	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1")
	await get_tree().process_frame
	SaveGameManager.allow_save_game = true

func load_saved_game() -> void:
	assert(
		not SaveGameManager.current_username.is_empty(),
		"GameManager.load_saved_game(): User harus login dulu!"
	)
	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1")
	await get_tree().process_frame
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true

# ─────────────────────────────────────────────
# KEMBALI KE MAIN MENU (dari dalam game)
# ─────────────────────────────────────────────
## Dipanggil oleh PauseMenu setelah get_tree().paused = false dijalankan.
func return_to_game_menu() -> void:
	# PENTING: paused sudah di-set false di pause_menu.gd sebelum fungsi ini.

	# 1. Auto-save
	if SaveGameManager.allow_save_game:
		SaveGameManager.save_game()

	# 2. Reset flag
	SaveGameManager.allow_save_game = false

	# 3. Fade-in overlay hitam
	var overlay_layer := CanvasLayer.new()
	overlay_layer.layer = 128
	overlay_layer.name  = "FadeOverlay"
	get_tree().root.add_child(overlay_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.add_child(overlay)

	var tween_in := overlay_layer.create_tween()
	tween_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_in.tween_property(overlay, "color:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween_in.finished

	# 4. Bersihkan game scene
	var main_root_path: String = SceneManager.main_scene_root_path
	if get_tree().root.has_node(main_root_path):
		get_tree().root.get_node(main_root_path).queue_free()
		await get_tree().process_frame
		await get_tree().process_frame

	# 5. Tampilkan Main Menu
	show_main_menu()

	# 6. Fade-out overlay
	var tween_out := overlay_layer.create_tween()
	tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(overlay, "color:a", 0.0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween_out.finished

	# 7. Hapus overlay
	overlay_layer.queue_free()

# ─────────────────────────────────────────────
# FUNGSI LAINNYA
# ─────────────────────────────────────────────

func exit_game() -> void:
	get_tree().quit()

func return_to_login() -> void:
	SaveGameManager.logout()
	var main_root_path: String = SceneManager.main_scene_root_path
	if get_tree().root.has_node(main_root_path):
		get_tree().root.get_node(main_root_path).queue_free()
		await get_tree().process_frame
	show_login_screen()

## Tampilkan Main Menu (pengganti show_game_menu_screen lama)
func show_main_menu() -> void:
	var instance: Node = main_menu_scene.instantiate()
	get_tree().root.add_child(instance)

## Alias backward-compatible jika ada kode lain yang masih memanggil ini
func show_game_menu_screen() -> void:
	show_main_menu()

## Tampilkan Pause Menu (dipanggil saat game sedang berjalan)
func show_pause_menu() -> void:
	# Hindari membuka dua pause menu sekaligus
	if get_tree().get_first_node_in_group("pause_menu"):
		return
	var pause_scene : PackedScene = preload("res://scenes/ui/game_pause_screen.tscn")
	var instance    : Node        = pause_scene.instantiate()
	get_tree().root.add_child(instance)
