extends Node

# =====================================================
# GAME DIALOGUE MANAGER
# Sinyal & fungsi yang bisa dipanggil dari file .dialogue
# =====================================================

# --- DAFTAR SINYAL ---
signal feed_the_animals
signal give_axe 
signal give_hoe
signal give_farming_kit
signal unlock_pesticide

# ⭐ BARU: Sinyal untuk quest perbaikan kapal & ending
signal start_ship_repair   # Dipanggil saat quest kapal dimulai
signal trigger_ending      # Dipanggil saat semua bahan terkumpul → load ending cutscene

# --- DAFTAR FUNGSI (Dipanggil dari file .dialogue dengan "do") ---

func action_feed_animals() -> void:
	feed_the_animals.emit()

func action_give_axe() -> void:
	give_axe.emit()

func action_give_hoe() -> void:
	give_hoe.emit()

func action_give_farming_kit() -> void:
	give_farming_kit.emit()

func action_unlock_pesticide() -> void:
	unlock_pesticide.emit()

# ⭐ BARU: Dipanggil dari mbah_kucing.dialogue saat quest kapal dimulai
func action_start_ship_repair() -> void:
	start_ship_repair.emit()
	print("🚢 Quest Perbaikan Kapal dimulai!")

# ⭐ BARU: Dipanggil dari mbah_kucing.dialogue setelah bahan diserahkan
func action_trigger_ending() -> void:
	trigger_ending.emit()
	print("🎬 Ending dipicu! Memuat ending cutscene...")
