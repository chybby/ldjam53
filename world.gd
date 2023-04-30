extends Node3D

signal day_ended

const PackageScene = preload("res://package/package.tscn")
const Package = preload("res://package/package.gd")
const CustomerScene = preload("res://customer/customer.tscn")

@onready var level := $Level
@onready var player := $Player
@onready var scanner := $Scanner
@onready var delivery_zone := $DeliveryZone
@onready var package_spawn_timer := $PackageSpawnTimer

var packages_left_to_spawn = 20
# Packages that don't have a customer waiting for them yet.
var unclaimed_packages: Array[Package] = []
# Packages that haven't been given to the right customer yet.
var undelivered_packages: Array[Package] = []

func start_day(day: int):
    print('Starting day %d' % day)
    packages_left_to_spawn = 20
    unclaimed_packages = []
    undelivered_packages = []
    player.reset()
    player.position = level.get_player_spawn_position()
    package_spawn_timer.start()

    for package in get_tree().get_nodes_in_group('packages'):
        package.free()

    # Reset the scanner in case a package was on it.
    scanner.reset()

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize()
    # TODO: Make sure 2 packages with the same name + address don't exist.
    package.position = level.get_package_spawn_position()
    add_child(package)
    unclaimed_packages.append(package)
    undelivered_packages.append(package)
    packages_left_to_spawn -= 1
    if packages_left_to_spawn == 0:
        package_spawn_timer.stop()

func _on_delivery_zone_package_delivered(package: Package):
    package.remove_from_group('pickup')
    player.drop_object()
    undelivered_packages.erase(package)
    print('packages left to deliver: %d' % undelivered_packages.size())

    # TODO: give the package to the customer at the start of the queue.
    package.queue_free()

    if undelivered_packages.is_empty():
        # TODO: fade out

        # End the day.
        day_ended.emit()

func _on_customer_spawn_timer_timeout():
    var customer := CustomerScene.instantiate()
    customer.setup(delivery_zone.position, level.get_customer_exit_position())
    print(level.get_customer_spawn_position())
    customer.position = level.get_customer_spawn_position()
    add_child(customer)
