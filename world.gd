extends Node3D

signal day_ended

const PackageScene = preload("res://package/package.tscn")
const Package = preload("res://package/package.gd")
const CustomerScene = preload("res://customer/customer.tscn")
const IDScene = preload("res://customer/id.tscn")

@onready var level := $Level
@onready var player := $Player
@onready var scanner := $Scanner
@onready var delivery_zone := $DeliveryZone
@onready var id_spawn_point := $DeliveryZone/IDSpawnPoint
@onready var package_spawn_timer := $PackageSpawnTimer

var id_queue = []
var customer_queue = []

var packages_left_to_spawn: int
var customers_left_to_spawn: int
# Packages that don't have a customer waiting for them yet.
var unclaimed_packages: Array[Package] = []
# Packages that haven't been given to the right customer yet.
var undelivered_packages: Array[Package] = []

func start_day(day: int):
    print('Starting day %d' % day)
    packages_left_to_spawn = 2
    customers_left_to_spawn = packages_left_to_spawn
    unclaimed_packages = []
    undelivered_packages = []
    player.reset()
    player.position = level.get_player_spawn_position()
    package_spawn_timer.start()
    level.turn_on_light()

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
        level.turn_off_light()

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
    if packages_left_to_spawn > 0 or customers_left_to_spawn == 0:
        return

    var customer := CustomerScene.instantiate()
    customer.position = level.get_customer_spawn_position()
    customer.needed_package = unclaimed_packages.pop_back()
    var p = delivery_zone
    if not customer_queue.is_empty():
        p = customer_queue[-1]
    customer_queue.push_back(customer)
    customer.setup(p, level.get_customer_exit_position())
    var customer_sprite = customer.get_node("Character")
    customer_sprite.modulate = Color(1,1,1,0)

    var id := IDScene.instantiate()
    id.position = id_spawn_point.global_position
    id.visible = false
    add_child(id)
    var id_ui := id.get_node("SubViewport/IDUI")
    id_ui.set_contents(
        customer.needed_package.first_name + "\n" + customer.needed_package.last_name,
        customer.needed_package.address._to_string()
    )
    id_queue.push_back(id)

    customers_left_to_spawn -= 1
    add_child(customer)
    var tween = get_tree().create_tween()
    tween.tween_property(customer_sprite, "modulate", Color(1,1,1,1), 1)
