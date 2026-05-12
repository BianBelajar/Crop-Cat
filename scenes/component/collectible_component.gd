class_name CollectibleComponent
extends Area2D
# =============================================================================
# collectible_component.gd — VERSI DIPERBAIKI
# Lokasi: res://scenes/component/collectible_component.gd
#
# PERBAIKAN:
#   • Tambah trigger achievement "first_harvest" saat item hasil panen diambil.
#     Item panen yang relevan: "tomato" dan "wheat".
#   • Tambah tracking counter bibit yang ditanam untuk achievement "plant_10"
#     (lihat catatan di bawah — plant_10 lebih baik ditaruh di tomato.gd/wheat.gd)
# =============================================================================

@export var collectable_name: String

## Nama-nama item yang dianggap sebagai "hasil panen" untuk achievement first_harvest
const HARVEST_ITEMS: Array[String] = ["tomato", "wheat"]


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		InventoryManager.add_collectable(collectable_name)
		print("Collected:", collectable_name)

		# ─── Cek Achievement: first_harvest ──────────────────────────────
		if collectable_name in HARVEST_ITEMS:
			print("✅ Quest [Panen Pertama] dicatat — item: ", collectable_name)
			print("🏆 Mencoba unlock Achievement: first_harvest")
			AchievementManager.unlock_achievement("first_harvest")

		get_parent().queue_free()
