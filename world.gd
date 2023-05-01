extends Node3D

signal day_ended
signal phone_call_started

const PackageScene = preload("res://package/package.tscn")
const Package = preload("res://package/package.gd")
const CustomerScene = preload("res://customer/customer.tscn")

@onready var level := $Level
@onready var player := $Player
@onready var scanner := $Scanner
@onready var delivery_zone := $DeliveryZone
@onready var id_spawn_point := $DeliveryZone/IDSpawnPoint
@onready var package_spawn_timer := $PackageSpawnTimer
@onready var phone := $Phone

var customer_queue = []

var packages_left_to_spawn: int
var customers_left_to_spawn: int
# Packages that don't have a customer waiting for them yet.
var unclaimed_packages: Array[Package] = []
# Packages that haven't been given to the right customer yet.
var undelivered_packages: Array[Package] = []

func start_day(day: int, skip_tutorial = false):
    print('Starting day %d' % day)
    packages_left_to_spawn = 20
    customers_left_to_spawn = packages_left_to_spawn
    unclaimed_packages = []
    undelivered_packages = []
    player.reset()
    delivery_zone.reset()
    player.position = level.get_player_spawn_position()
    if day == 0 and not skip_tutorial:
        player.position = level.get_player_tutorial_spawn_position()
        player.rotation = level.get_player_tutorial_spawn_rotation()

    for package in get_tree().get_nodes_in_group('packages'):
        package.free()

    for customer in get_tree().get_nodes_in_group('customers'):
        customer.free()

    customer_queue = []

    # Reset the scanner in case a package was on it.
    scanner.reset()

    if skip_tutorial or day > 0:
        start_package_spawning()
    else:
        phone.start_ringing()

func start_package_spawning():
    package_spawn_timer.start()
    level.turn_on_light()

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize_attributes()
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

    package.queue_free()

    if undelivered_packages.is_empty():
        await get_tree().create_timer(3.0).timeout
        # End the day.
        day_ended.emit()

func _on_customer_spawn_timer_timeout():
    if packages_left_to_spawn > 0 or customers_left_to_spawn == 0:
        return

    var customer := CustomerScene.instantiate()
    customer.position = level.get_customer_spawn_position()
    var follow_target = delivery_zone
    if not customer_queue.is_empty():
        follow_target = customer_queue[-1]
    customer_queue.push_back(customer)
    var customer_sprite = customer.get_node("Character")
    customer_sprite.modulate = Color(1,1,1,0)

    var package = unclaimed_packages.pop_at(randi() % unclaimed_packages.size())
    customer.setup(follow_target, level.get_customer_exit_position(), package)

    customers_left_to_spawn -= 1
    add_child(customer)
    var tween = get_tree().create_tween()
    tween.tween_property(customer_sprite, "modulate", Color(1,1,1,1), 1)

func _on_phone_call_started():
    player.can_move = false
    phone_call_started.emit()

func finish_call():
    phone.finish_call()
    player.can_move = true
    start_package_spawning()
