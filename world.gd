extends Node3D

var PackageScene = preload("res://package/package.tscn")
var Package = preload("res://package/package.gd")

@onready var level := $Level

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.shape = Package.get_random_shape()
    package.size = Package.get_random_size()
    package.company = Package.get_random_company()
    package.position = level.get_package_spawn_position()
    add_child(package)
