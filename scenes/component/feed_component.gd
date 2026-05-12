class_name FeedComponent
extends Area2D
# =============================================================================
# feed_component.gd — VERSI DIPERBAIKI
# Lokasi: res://scenes/component/feed_component.gd
#
# PERBAIKAN:
#   • Tambah trigger achievement "feed_animal" saat makanan pertama kali
#     masuk ke kandang (area ini dimasuki oleh item makanan/panen).
# =============================================================================

signal food_received(area: Area2D)


func _on_area_entered(area: Area2D) -> void:
	food_received.emit(area)

	# ─── Trigger Achievement: feed_animal ────────────────────────────────
	# Area ini dimasuki saat item panen (tomato/wheat) dilempar ke kandang.
	# Cukup unlock sekali — AchievementManager sudah punya guard is_unlocked.
	print("✅ Quest [Beri Makan Hewan] dicatat — makanan masuk kandang")
	print("🏆 Mencoba unlock Achievement: feed_animal")
	AchievementManager.unlock_achievement("feed_animal")
