# =============================================================================
# collectible_component.gd — VERSI DIPERBAIKI (BUG collect_wood FIXED)
# Lokasi: res://scenes/component/collectible_component.gd
# =============================================================================
class_name CollectibleComponent
extends Area2D

@export var collectable_name: String

## Item yang dianggap sebagai "hasil panen" → achievement first_harvest
const HARVEST_ITEMS: Array[String] = ["tomato", "wheat"]

## Item yang dianggap sebagai "kayu" → achievement collect_wood
## "log" adalah collectable_name yang diset di log.tscn
const WOOD_ITEMS: Array[String] = ["log"]


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		InventoryManager.add_collectable(collectable_name)
		print("Collected: ", collectable_name)

		# ─── Achievement: first_harvest (Panen Pertama) ───────────────────────
		if collectable_name in HARVEST_ITEMS:
			print("✅ Quest [Panen Pertama] dicatat — item: ", collectable_name)
			AchievementManager.unlock_achievement("first_harvest")

		# ─── Achievement: collect_wood (Penebang Hutan) ───────────────────────
		# "log" adalah nama yang di-set di log.tscn pada node CollectibleComponent
		if collectable_name in WOOD_ITEMS:
			print("🏆 Achievement Kayu dipicu!")  # ← Debug print sesuai permintaan
			AchievementManager.unlock_achievement("collect_wood")

		get_parent().queue_free()
