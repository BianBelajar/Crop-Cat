## login_screen.gd
## Scene Login — layar pertama yang dilihat pemain sebelum masuk ke game.
## Pemain cukup mengetik nama, lalu klik "Masuk" atau tekan Enter.
extends CanvasLayer

# ─────────────────────────────────────────────
# NODE REFERENCES
# ─────────────────────────────────────────────
@onready var username_input: LineEdit      = $CenterContainer/Panel/VBoxContainer/UsernameInput
@onready var login_button: Button          = $CenterContainer/Panel/VBoxContainer/LoginButton
@onready var error_label: Label            = $CenterContainer/Panel/VBoxContainer/ErrorLabel
@onready var profiles_container: VBoxContainer = $CenterContainer/Panel/VBoxContainer/ProfilesContainer
@onready var profiles_list: VBoxContainer  = $CenterContainer/Panel/VBoxContainer/ProfilesContainer/ProfilesList
@onready var new_game_label: Label         = $CenterContainer/Panel/VBoxContainer/NewGameLabel

# ─────────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────────
func _ready() -> void:
	error_label.hide()
	new_game_label.hide()

	# Fokus otomatis ke input field
	username_input.grab_focus()

	# Sambungkan sinyal Enter pada LineEdit
	username_input.text_submitted.connect(_on_username_submitted)
	username_input.text_changed.connect(_on_username_text_changed)
	login_button.pressed.connect(_on_login_button_pressed)

	# Tampilkan profil yang sudah ada
	_populate_existing_profiles()

# ─────────────────────────────────────────────
# UI HANDLERS
# ─────────────────────────────────────────────

func _on_username_text_changed(_new_text: String) -> void:
	error_label.hide()
	var trimmed: String = username_input.text.strip_edges()
	_update_new_game_hint(trimmed)

func _on_username_submitted(text: String) -> void:
	_attempt_login(text)

func _on_login_button_pressed() -> void:
	_attempt_login(username_input.text)

# ─────────────────────────────────────────────
# LOGIC
# ─────────────────────────────────────────────

func _attempt_login(raw_username: String) -> void:
	var trimmed: String = raw_username.strip_edges()

	if trimmed.is_empty():
		_show_error("Nama tidak boleh kosong!")
		return

	if trimmed.length() < 2:
		_show_error("Nama minimal 2 karakter.")
		return

	if trimmed.length() > 20:
		_show_error("Nama maksimal 20 karakter.")
		return

	# Login berhasil — serahkan ke SaveGameManager
	SaveGameManager.login_as(trimmed)

	# Pindah ke menu utama atau langsung ke game
	_proceed_to_main_menu()

func _proceed_to_main_menu() -> void:
	# Tampilkan game menu screen (yang sudah ada di project)
	# GameManager akan menangani start_game() / load_saved_game() dari sana
	var game_menu: PackedScene = preload("res://scenes/ui/game_menu_screen.tscn")
	var instance: Node = game_menu.instantiate()
	get_tree().root.add_child(instance)
	queue_free()

func _populate_existing_profiles() -> void:
	var profiles: Array[String] = SaveGameManager.get_existing_profiles()

	if profiles.is_empty():
		profiles_container.hide()
		return

	profiles_container.show()

	# Hapus tombol lama jika ada (untuk hot-reload)
	for child: Node in profiles_list.get_children():
		child.queue_free()

	for profile_name: String in profiles:
		var btn: Button = Button.new()
		btn.text = "▶  " + profile_name
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		# Capture nama di closure
		btn.pressed.connect(_on_profile_button_pressed.bind(profile_name))
		profiles_list.add_child(btn)

func _on_profile_button_pressed(profile_name: String) -> void:
	username_input.text = profile_name
	_attempt_login(profile_name)

func _update_new_game_hint(username: String) -> void:
	if username.is_empty():
		new_game_label.hide()
		return

	var exists: bool = SaveGameManager \
		.get_existing_profiles() \
		.has(username.to_lower())

	if exists:
		new_game_label.text = "✓ Melanjutkan save: " + username
	else:
		new_game_label.text = "✨ Profil baru akan dibuat untuk: " + username
	new_game_label.show()

# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────

func _show_error(message: String) -> void:
	error_label.text = "⚠ " + message
	error_label.show()
