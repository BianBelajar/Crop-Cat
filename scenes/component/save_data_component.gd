class_name SaveDataComponent
extends Node

@onready var parent_node: Node2D = get_parent() as Node2D

# 1. PERBAIKAN: Ubah Resource menjadi NodeDataResource
@export var save_data_resource: NodeDataResource

func _ready() -> void:
	add_to_group("save_data_component")

# 2. PERBAIKAN: Return type juga diubah jadi NodeDataResource
func _save_data() -> NodeDataResource:
	if parent_node == null:
		return null

	if save_data_resource == null:
		push_error("save_data_resource:", save_data_resource, parent_node.name)
		return null
	
	save_data_resource._save_data(parent_node)
	
	# --- TAMBAHKAN BARIS INI (Bagian B) ---
	# Mengecek ke tanaman (parent) apakah dia punya variabel has_pest
	if "has_pest" in parent_node:
		save_data_resource.has_pest = parent_node.has_pest
	# --------------------------------------
	
	return save_data_resource
