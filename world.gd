extends Node3D

var PackageScene = preload("res://package/package.tscn")
var CustomerScene = preload("res://customer/customer.tscn")

@onready var level := $Level
@onready var customer_entry_position := $Level/CustomerEntryPoint
@onready var package_spawn_timer := $PackageSpawnTimer

var packages_left = 15

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize()
    package.position = level.get_package_spawn_position()
    add_child(package)
    packages_left -= 1
    if packages_left == 0:
        package_spawn_timer.stop()


func _on_customer_spawn_timer_timeout():
    var customer := CustomerScene.instantiate()
    customer.position = customer_entry_position.position
    add_child(customer)
