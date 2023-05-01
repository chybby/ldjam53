extends Node3D

signal day_ended(packages: int, seconds: int)
signal phone_call_started
signal all_packages_spawned

const PackageScene = preload("res://package/package.tscn")
const Package = preload("res://package/package.gd")
const CustomerScene = preload("res://customer/customer.tscn")
const CarScene = preload("res://car/car.tscn")

@onready var level := $Level
@onready var player := $Player
@onready var scanner := $Scanner
@onready var delivery_zone := $DeliveryZone
@onready var store_opener := $StoreOpener
@onready var id_spawn_point := $DeliveryZone/IDSpawnPoint
@onready var package_spawn_timer := $PackageSpawnTimer
@onready var customer_spawn_timer := $CustomerSpawnTimer
@onready var phone := $Phone
@onready var package_display_label := $PackageDisplay/Label3D
@onready var quit_job_button := $QuitJobButton

var customer_queue = []

var packages_left_to_spawn: int
var customers_left_to_spawn: int
# Packages that don't have a customer waiting for them yet.
var unclaimed_packages: Array[Package] = []
# Packages that haven't been given to the right customer yet.
var undelivered_packages: Array[Package] = []

var packages_delivered := 0
var start_time := 0

var current_day := 0

func _ready():
    player.position = level.get_player_tutorial_spawn_position()
    player.rotation = level.get_player_tutorial_spawn_rotation()
    player.camera.rotate_x(.25)
    remove_child(quit_job_button)

func start_day(day: int, skip_tutorial = false):
    print('Starting day %d' % day)
    current_day = day
    match day:
        0:
            packages_left_to_spawn = 5
            package_spawn_timer.wait_time = 10
        1:
            packages_left_to_spawn = 15
            package_spawn_timer.wait_time = 5
        2:
            packages_left_to_spawn = 200
            package_spawn_timer.wait_time = 0.5
    customers_left_to_spawn = packages_left_to_spawn
    unclaimed_packages = []
    undelivered_packages = []
    packages_delivered = 0
    player.reset()
    player.position = level.get_player_tutorial_spawn_position()
    player.rotation = level.get_player_tutorial_spawn_rotation()
    player.camera.rotate_x(.25)
    delivery_zone.reset()
    store_opener.reset()
    package_display_label.text = ''

    for package in get_tree().get_nodes_in_group('packages'):
        package.free()

    for customer in get_tree().get_nodes_in_group('customers'):
        customer.free()

    customer_queue = []

    # Reset the scanner in case a package was on it.
    scanner.reset()

    if skip_tutorial:
        start_package_spawning()
    else:
        phone.start_ringing()

func start_package_spawning():
    if current_day == 2:
        remove_child(store_opener)
        add_child(quit_job_button)
        quit_job_button.visible = true
    package_display_label.text = '???' if current_day == 2 else str(packages_left_to_spawn)
    package_spawn_timer.start()
    level.turn_on_light()
    _on_package_spawn_timer_timeout()
    start_time = Time.get_ticks_msec()

func _on_package_spawn_timer_timeout():
    var package := PackageScene.instantiate()
    package.randomize_attributes()
    # TODO: Make sure 2 packages with the same name + address don't exist.
    package.position = level.get_package_spawn_position()
    add_child(package)
    unclaimed_packages.append(package)
    undelivered_packages.append(package)
    packages_left_to_spawn -= 1
    package_display_label.text = '???' if current_day == 2 else str(packages_left_to_spawn)
    if packages_left_to_spawn == 0:
        package_spawn_timer.stop()
        all_packages_spawned.emit()
        level.turn_off_light()

func _on_delivery_zone_package_delivered(package: Package):
    package.remove_from_group('pickup')
    player.drop_object()
    undelivered_packages.erase(package)
    packages_delivered += 1
    print('packages left to deliver: %d' % undelivered_packages.size())

    package.queue_free()

    if undelivered_packages.is_empty():
        await get_tree().create_timer(3.0).timeout
        # End the day.
        day_ended.emit(packages_delivered, (Time.get_ticks_msec() - start_time)/1000)

func start_customer_spawning():
    customer_spawn_timer.start()

func _on_customer_spawn_timer_timeout():
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

    if customers_left_to_spawn == 0:
        customer_spawn_timer.stop()

func _on_phone_call_started():
    player.can_move = false
    phone_call_started.emit()

func finish_call():
    phone.finish_call()
    player.can_move = true
    start_package_spawning()

func _on_store_opener_store_opened():
    print("store opened")
    start_customer_spawning()

func _on_car_spawn_timer_timeout():
    var car := CarScene.instantiate()
    var x = randi_range(1,2)
    if x == 1:
        car.position = level.get_car_spawn1_position()
        car.rotation = level.get_car_spawn1_rotation()
        car.flip = false
    else:
        car.position = level.get_car_spawn2_position()
        car.flip = true
    add_child(car)
