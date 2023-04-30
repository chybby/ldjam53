extends Node3D

@onready var package_spawn_point := $PackageSpawnPoint
@onready var player_spawn_point := $PlayerSpawnPoint
@onready var customer_spawn_point := $CustomerSpawnPoint
@onready var customer_exit_area := $CustomerExitArea

func get_player_spawn_position():
    return player_spawn_point.global_position

func get_package_spawn_position():
    return package_spawn_point.global_position

func get_customer_spawn_position():
    return customer_spawn_point.global_position

func get_customer_exit_position():
    return customer_exit_area.global_position
