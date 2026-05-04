## user_indicator_hud.gd
## HUD kecil yang menampilkan "Login sebagai: [Nama User]" di dalam level.
## Tambahkan scene ini sebagai child dari game_screen.tscn atau main_scene.tscn.
extends CanvasLayer

@onready var label: Label = $MarginContainer/UserLabel

func _ready() -> void:
	# Tampilkan nama user saat ini
	_update_label(SaveGameManager.current_username)

	# Update otomatis jika user berganti (misalnya saat logout)
	SaveGameManager.user_changed.connect(_update_label)

func _update_label(username: String) -> void:
	if username.is_empty():
		label.text = ""
		label.hide()
	else:
		label.text = "🌾 Login sebagai: " + username
		label.show()
