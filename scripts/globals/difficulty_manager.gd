extends Node

# Daftar tingkat kesulitan
enum Level { EASY, NORMAL, HARD }
var current_level: Level = Level.NORMAL

# Variabel yang akan dipanggil oleh tanaman (default 20%)
var pest_chance: float = 0.20 

# Fungsi ini dipanggil dari game_menu_screen saat tombol difficulty ditekan
func set_difficulty(level: Level) -> void:
	current_level = level
	
	match current_level:
		Level.EASY:
			pest_chance = 0.05 # Hama langka (Cuma 5%)
			print("Mode EASY: Peluang hama 5%")
		Level.NORMAL:
			pest_chance = 0.20 # Normal (20%)
			print("Mode NORMAL: Peluang hama 20%")
		Level.HARD:
			pest_chance = 0.60 # Hama ganas! (60%)
			print("Mode HARD: Peluang hama 60%")
