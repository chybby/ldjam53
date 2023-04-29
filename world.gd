extends Node3D

var PackageScene = preload("res://package/package.tscn")

@onready var level := $Level
@onready var package_spawn_timer := $PackageSpawnTimer

var packages_left = 10

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize()
    package.position = level.get_package_spawn_position()
    add_child(package)

    packages_left -= 1
    if packages_left == 0:
        package_spawn_timer.stop()
