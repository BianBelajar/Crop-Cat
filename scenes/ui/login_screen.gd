## login_screen.gd
## Scene  : res://scenes/ui/login_screen.tscn
## Extends: CanvasLayer

extends CanvasLayer

# ─────────────────────────────────────────────
# NODE REFERENCES — path baru karena ada ScrollContainer
# ─────────────────────────────────────────────
@onready var username_input     : LineEdit      = $CenterContainer/Panel/MarginContainer/MainVBox/UsernameInput
@onready var login_button       : Button        = $CenterContainer/Panel/MarginContainer/MainVBox/LoginButton
@onready var exit_button        : Button        = $CenterContainer/Panel/MarginContainer/MainVBox/ExitButton
@onready var error_label        : Label         = $CenterContainer/Panel/MarginContainer/MainVBox/ErrorLabel
@onready var new_game_label     : Label         = $CenterContainer/Panel/MarginContainer/MainVBox/NewGameLabel
@onready var profiles_container : VBoxContainer = $CenterContainer/Panel/MarginContainer/MainVBox/ProfilesContainer
@onready var profiles_list      : VBoxContainer = $CenterContainer/Panel/MarginContainer/MainVBox/ProfilesContainer/ProfilesList
@onready var logo_texture       : Label         = $CenterContainer/Panel/MarginContainer/MainVBox/LogoContainer/LogoTexture

# ─────────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────────
func _ready() -> void:
	error_label.hide()
	new_game_label.hide()

	username_input.text_submitted.connect(_on_username_submitted)
	username_input.text_changed.connect(_on_username_text_changed)
	login_button.pressed.connect(_on_login_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	_populate_existing_profiles()
	_start_logo_float_animation()
	_animate_screen_in()
	username_input.grab_focus()


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

func _on_exit_button_pressed() -> void:
	_animate_screen_out(func(): get_tree().quit())


# ─────────────────────────────────────────────
# LOGIC LOGIN
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

	login_button.disabled = true
	SaveGameManager.login_as(trimmed)
	_animate_screen_out(_proceed_to_main_menu)


func _proceed_to_main_menu() -> void:
	# Gunakan main_menu.tscn (scene baru) atau game_menu_screen.tscn (scene lama)
	# Sesuaikan path di bawah dengan nama scene yang kamu pakai
	var main_menu: PackedScene = preload("res://scenes/ui/game_menu_screen.tscn")
	var instance: Node = main_menu.instantiate()
	get_tree().root.add_child(instance)
	queue_free()


# ─────────────────────────────────────────────
# PROFIL TERSIMPAN
# ─────────────────────────────────────────────

func _populate_existing_profiles() -> void:
	var profiles: Array[String] = SaveGameManager.get_existing_profiles()
	if profiles.is_empty():
		profiles_container.hide()
		return

	profiles_container.show()
	for child: Node in profiles_list.get_children():
		child.queue_free()
	for profile_name: String in profiles:
		var btn: Button = Button.new()
		btn.text = "▶  " + profile_name
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_profile_button_pressed.bind(profile_name))
		profiles_list.add_child(btn)

func _on_profile_button_pressed(profile_name: String) -> void:
	username_input.text = profile_name
	_attempt_login(profile_name)


# ─────────────────────────────────────────────
# HINT
# ─────────────────────────────────────────────

func _update_new_game_hint(username: String) -> void:
	if username.is_empty():
		new_game_label.hide()
		return
	var exists: bool = SaveGameManager.get_existing_profiles().has(username.to_lower())
	if exists:
		new_game_label.text = "✓ Melanjutkan save: " + username
	else:
		new_game_label.text = "✨ Profil baru: " + username
	new_game_label.show()


# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────

func _show_error(message: String) -> void:
	error_label.text = "⚠ " + message
	error_label.show()
	_shake_node(username_input)


# ─────────────────────────────────────────────
# ANIMASI
# ─────────────────────────────────────────────

func _start_logo_float_animation() -> void:
	if not is_instance_valid(logo_texture):
		return
	var origin_y: float = logo_texture.position.y
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(logo_texture, "position:y", origin_y - 8.0, 1.4) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(logo_texture, "position:y", origin_y, 1.4) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _animate_screen_in() -> void:
	# CanvasLayer tidak punya modulate — animasikan child pertama (Background)
	var root_control: CanvasItem = get_child(0)
	if not is_instance_valid(root_control):
		return
	root_control.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(root_control, "modulate:a", 1.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _animate_screen_out(callback: Callable) -> void:
	var root_control: CanvasItem = get_child(0)
	if not is_instance_valid(root_control):
		callback.call()
		return
	var tween := create_tween()
	tween.tween_property(root_control, "modulate:a", 0.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	callback.call()

func _shake_node(node: Control) -> void:
	if not is_instance_valid(node):
		return
	var origin_x: float = node.position.x
	var tween := create_tween()
	tween.tween_property(node, "position:x", origin_x + 6.0, 0.05)
	tween.tween_property(node, "position:x", origin_x - 6.0, 0.05)
	tween.tween_property(node, "position:x", origin_x + 4.0, 0.04)
	tween.tween_property(node, "position:x", origin_x - 4.0, 0.04)
	tween.tween_property(node, "position:x", origin_x,       0.03)
