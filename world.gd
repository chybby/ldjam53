extends Node3D

var PackageScene = preload("res://package/package.tscn")

@onready var level := $Level

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize()
    package.position = level.get_package_spawn_position()
    add_child(package)
