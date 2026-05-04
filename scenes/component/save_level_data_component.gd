## save_level_data_component.gd  (MODIFIKASI)
## Perubahan utama: path file save kini berasal dari SaveGameManager
## agar mengikuti username yang sedang aktif.
class_name SaveLevelDataComponent
extends Node

var level_scene_name: String
var game_data_resource: SaveGameDataResource

func _ready() -> void:
	add_to_group("save_level_data_component")
	level_scene_name = get_parent().name

# ─────────────────────────────────────────────
# SAVE
# ─────────────────────────────────────────────

func save_node_data() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group("save_data_component")
	game_data_resource = SaveGameDataResource.new()

	game_data_resource.inventory_data = InventoryManager.inventory.duplicate(true)
	game_data_resource.game_time      = DayAndNightCycleManager.time

	# Iterasi sekali saja — hindari duplikasi data yang ada di versi lama
	for node: Node in nodes:
		if node is SaveDataComponent:
			var save_data_resource: NodeDataResource = node._save_data()
			if save_data_resource != null:
				game_data_resource.save_data_nodes.append(save_data_resource.duplicate())


func save_game() -> void:
	# ⭐ Path kini didelegasikan ke SaveGameManager (per-user)
	var save_path: String = SaveGameManager.get_level_save_path(level_scene_name)

	save_node_data()

	var result: int = ResourceSaver.save(game_data_resource, save_path)
	if result != OK:
		push_error("[SaveLevelDataComponent] Gagal menyimpan! Error code: %d | Path: %s" % [result, save_path])
	else:
		print("[SaveLevelDataComponent] Tersimpan: " + save_path)

# ─────────────────────────────────────────────
# LOAD
# ─────────────────────────────────────────────

func load_game() -> void:
	# ⭐ Path kini didelegasikan ke SaveGameManager (per-user)
	var save_path: String = SaveGameManager.get_level_save_path(level_scene_name)

	if not FileAccess.file_exists(save_path):
		print("[SaveLevelDataComponent] Tidak ada save di: " + save_path)
		return

	var loaded_resource: Resource = ResourceLoader.load(save_path)
	if loaded_resource == null or not (loaded_resource is SaveGameDataResource):
		push_error("[SaveLevelDataComponent] File save rusak atau bukan SaveGameDataResource.")
		return

	game_data_resource = loaded_resource as SaveGameDataResource

	# Kembalikan inventory
	InventoryManager.inventory = game_data_resource.inventory_data.duplicate(true)
	InventoryManager.inventory_changed.emit()

	# Kembalikan waktu
	DayAndNightCycleManager.time = game_data_resource.game_time

	# Kembalikan data node (TileMap, posisi player, tanaman, dll.)
	var root_node: Window = get_tree().root
	for resource: Resource in game_data_resource.save_data_nodes:
		if resource is NodeDataResource:
			resource._load_data(root_node)

	print("[SaveLevelDataComponent] Dimuat: " + save_path)
