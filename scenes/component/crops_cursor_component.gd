class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer : TileMapLayer

@onready var player: Player = get_tree().get_first_node_in_group("player")

var wheat_plant_scene = preload("res://scenes/objects/plants/wheat.tscn")
var tomato_plant_scene = preload("res://scenes/objects/plants/tomato.tscn")

var mouse_position: Vector2
var cell_position: Vector2
var cell_source_id : int
var local_cell_position: Vector2
var distance: float

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_cell_under_mouse()
			remove_crop()
	elif event.is_action_pressed("hit"):
		if ToolManager.selected_tool == DataTypes.Tools.PlantWheat or ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
			get_cell_under_mouse()
			add_crop()

func get_cell_under_mouse() -> void:
	mouse_position = tilled_soil_tilemap_layer.get_local_mouse_position()
	cell_position = tilled_soil_tilemap_layer.local_to_map(mouse_position)
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(tilled_soil_tilemap_layer.to_global(local_cell_position))

func add_crop() -> void:
	if distance < 20.0 and cell_source_id != -1:
		var crops_field = get_parent().find_child("CropsFields")
		var target_position = tilled_soil_tilemap_layer.to_global(local_cell_position)
		
		# CEK DULU: Apakah sudah ada tanaman di kotak ini?
		var is_occupied = false
		for crop in crops_field.get_children():
			# Kalau ada tanaman yang posisinya sama persis dengan tempat klik kita
			if crop.global_position == target_position:
				is_occupied = true
				break
		
		# JIKA KOSONG (Belum ada tanaman), maka baru boleh ditanam
		if not is_occupied:
			if ToolManager.selected_tool == DataTypes.Tools.PlantWheat:
				var wheat_instance = wheat_plant_scene.instantiate() as Node2D
				crops_field.add_child(wheat_instance)
				wheat_instance.global_position = target_position
			
			if ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
				var tomato_instance = tomato_plant_scene.instantiate() as Node2D
				crops_field.add_child(tomato_instance)
				tomato_instance.global_position = target_position


func remove_crop() -> void:
	# Kita tidak perlu mengecek cell_source_id != -1 di sini, 
	# karena tanahnya mungkin sudah dihapus duluan oleh field_cursor_component!
	if distance < 20.0:
		var crops_field = get_parent().find_child("CropsFields")
		var target_position = tilled_soil_tilemap_layer.to_global(local_cell_position)
		
		# Cek semua tanaman yang ada di ladang
		for crop in crops_field.get_children():
			# Jika posisi tanaman sama persis dengan kotak tanah yang kita hapus...
			if crop.global_position == target_position:
				crop.queue_free() # Hapus tanaman tersebut!
