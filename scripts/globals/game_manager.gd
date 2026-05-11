## game_manager.gd
extends Node

var game_menu_screen: PackedScene = preload("res://scenes/ui/game_menu_screen.tscn")

# ── Shortcut keyboard untuk membuka game menu ────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		show_game_menu_screen()

func show_login_screen() -> void:
	var login_scene: PackedScene = preload("res://scenes/ui/login_screen.tscn")
	var instance: Node = login_scene.instantiate()
	get_tree().root.add_child(instance)

# ─────────────────────────────────────────────
# GAME FLOW
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
# KEMBALI KE GAME MENU
# ─────────────────────────────────────────────

func return_to_game_menu() -> void:
	# PENTING: get_tree().paused sudah di-set false di game_menu_screen.gd
	# sebelum fungsi ini dipanggil. Jangan set ulang di sini.

	# 1. Auto-save
	if SaveGameManager.allow_save_game:
		SaveGameManager.save_game()

	# 2. Reset flag
	SaveGameManager.allow_save_game = false

	# 3. Fade in overlay hitam di root — KITA yang pegang referensinya
	#    sehingga kita bisa hapus sendiri setelah selesai.
	var overlay_layer := CanvasLayer.new()
	overlay_layer.layer = 128
	overlay_layer.name = "FadeOverlay"
	get_tree().root.add_child(overlay_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.add_child(overlay)

	# Tween HARUS pakai TWEEN_PAUSE_PROCESS agar tidak stuck saat paused
	var tween_in := overlay_layer.create_tween()
	tween_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_in.tween_property(overlay, "color:a", 1.0, 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween_in.finished

	# 4. Bersihkan game scene
	var main_root_path: String = SceneManager.main_scene_root_path
	if get_tree().root.has_node(main_root_path):
		get_tree().root.get_node(main_root_path).queue_free()
		# Tunggu benar-benar terhapus dari tree
		await get_tree().process_frame
		await get_tree().process_frame

	# 5. Tampilkan game menu
	show_game_menu_screen()

	# 6. Fade OUT overlay — hapus setelah selesai
	var tween_out := overlay_layer.create_tween()
	tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(overlay, "color:a", 0.0, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween_out.finished

	# 7. Hapus overlay — dijamin bersih
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

func show_game_menu_screen() -> void:
	var instance: Node = game_menu_screen.instantiate()
	get_tree().root.add_child(instance)
