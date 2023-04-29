extends Node3D

@onready var package_spawn_point := $PackageSpawnPoint
@onready var player_spawn_point := $PlayerSpawnPoint

func get_player_spawn_position():
    return player_spawn_point.position

func get_package_spawn_position():
    return package_spawn_point.position
