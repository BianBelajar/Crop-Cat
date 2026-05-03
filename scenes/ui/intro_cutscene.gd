extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var subtitle_label: Label = $Panel/Label

# Ubah bagian cutscene_data menjadi seperti ini:
var cutscene_data = [
	{
		"image": preload("res://assets/intro/jelajah.png"), # Gambar 1: Berlayar
		"text": "Suatu hari, aku sedang berlayar menjelajahi lautan Nusantara yang indah..."
	},
	{
		"image": preload("res://assets/intro/badai.png"), # Gambar 2: Kena badai
		"text": "Namun tiba-tiba, badai dahsyat datang mengamuk dan menghantam kapalku!"
	},
	{
		"image": preload("res://assets/intro/terdampar.png"), # Gambar 3: Terdampar pingsan
		"text": "Kapalku hancur lebur... dan aku terdampar pingsan di pantai pulau yang tak kukenal."
	},
	{
		"image": preload("res://assets/intro/selamat.png"), # Gambar 4: Ditolong kakek
		"text": "Beruntung, seorang kakek kucing yang baik hati menemukanku dan membawaku ke rumahnya..."
	}
]

var current_slide: int = 0

func _ready() -> void:
	# Tampilkan gambar dan teks pertama saat scene dimulai
	show_slide(current_slide)

func _input(event: InputEvent) -> void:
	# Jika pemain klik kiri mouse atau tekan Spasi/Enter
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		next_slide()

func show_slide(index: int) -> void:
	texture_rect.texture = cutscene_data[index]["image"]
	subtitle_label.text = cutscene_data[index]["text"]

func next_slide() -> void:
	current_slide += 1
	
	if current_slide < cutscene_data.size():
		show_slide(current_slide)
	else:
		finish_cutscene()

func finish_cutscene() -> void:
	print("Cutscene selesai, masuk ke game utama!")
	QuestManager.is_intro_done = true # <-- BUKA GEMBOKNYA DI SINI
	GameManager.start_game()
	queue_free()
