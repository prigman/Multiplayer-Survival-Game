@tool

extends MOctree

func _init() -> void:
	enable_as_curve_updater()
	enable_as_octmesh_updater()
	set_lod_setting([10,20,60,160,300,600])