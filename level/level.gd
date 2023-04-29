extends Node3D

@onready var package_spawn_point := $PackageSpawnPoint

func get_package_spawn_position():
    return package_spawn_point.position
