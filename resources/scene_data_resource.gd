class_name SceneDataResource
extends NodeDataResource

@export var node_name: String
@export var scene_file_path: String
@export var has_pest: bool = false

func _save_data(node: Node2D) -> void:
	super._save_data(node)
	
	node_name = node.name
	scene_file_path = node.scene_file_path
	
func _load_data(window: Window) -> void:
	var parent_node = window.get_node_or_null(parent_node_path) 
	if parent_node != null:
		var scene_file_resource = load(scene_file_path)
		var scene_node: Node2D = scene_file_resource.instantiate() as Node2D
		parent_node.add_child(scene_node)
		scene_node.global_position = global_position
		scene_node.name = node_name
		
		if "has_pest" in scene_node:
			scene_node.has_pest = has_pest
			if scene_node.has_pest:
				scene_node.spawn_pest()
