extends Node3D

var PackageScene = preload("res://package/package.tscn")
var CustomerScene = preload("res://customer/customer.tscn")

@onready var level := $Level
@onready var customer_entry_position := $Level/CustomerEntryPoint

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize()
    package.position = level.get_package_spawn_position()
    add_child(package)


func _on_customer_spawn_timer_timeout():
    var customer := CustomerScene.instantiate()
    customer.position = customer_entry_position.position
    add_child(customer)
