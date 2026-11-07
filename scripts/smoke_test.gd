extends SceneTree

func _initialize() -> void:
	var scene := load("res://scenes/TownScene.tscn")
	if scene == null:
		print("SMOKE_FAIL load scene")
		quit(1)
		return
	var node = scene.instantiate()
	root.add_child(node)
	await process_frame
	await process_frame
	print("SMOKE_OK children=", node.get_child_count())
	quit(0)
