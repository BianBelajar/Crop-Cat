extends CanvasLayer

@onready var label: Label = $MarginContainer/UserLabel
@onready var jurnal_button: Button = $JurnalButton

func _ready() -> void:
	_update_label(SaveGameManager.current_username)
	SaveGameManager.user_changed.connect(_update_label)

	jurnal_button.pressed.connect(_on_jurnal_pressed)

	# Update visibility setiap quest step berubah
	QuestManager.quest_step_changed.connect(func(_s): _update_jurnal_button_visibility())

	# Update visibility setelah game di-load (clue sudah terisi)
	QuestManager.quest_loaded_signal.connect(_update_jurnal_button_visibility)

	# Cek kondisi awal (misalnya resume game yang sudah punya quest)
	_update_jurnal_button_visibility()

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
	# Tombol muncul jika sudah ada quest (step >= 1) DAN ada teks clue tersimpan
	jurnal_button.visible = QuestManager.quest_step >= 1 and not QuestManager.clue_quest_aktif.is_empty()
