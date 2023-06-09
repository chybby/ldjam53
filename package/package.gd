@tool
extends RigidBody3D

enum Shape {BOX, TUBE}
enum Size {SMALL, MEDIUM, LARGE}
enum Company {PERSONAL_DELIVERY_CONGLOMERATE, LOGISTICS_CORP, SHIP_FOR_LESS}

const box_large_mesh = preload("res://package/meshes/box_large_mesh.tres")
const box_medium_mesh = preload("res://package/meshes/box_medium_mesh.tres")
const box_small_mesh = preload("res://package/meshes/box_small_mesh.tres")
const tube_large_mesh = preload("res://package/meshes/tube_large_mesh.tres")
const tube_medium_mesh = preload("res://package/meshes/tube_medium_mesh.tres")
const tube_small_mesh = preload("res://package/meshes/tube_small_mesh.tres")

const box_large_shape = preload("res://package/shapes/box_large_shape.tres")
const box_medium_shape = preload("res://package/shapes/box_medium_shape.tres")
const box_small_shape = preload("res://package/shapes/box_small_shape.tres")
const tube_large_shape = preload("res://package/shapes/tube_large_shape.tres")
const tube_medium_shape = preload("res://package/shapes/tube_medium_shape.tres")
const tube_small_shape = preload("res://package/shapes/tube_small_shape.tres")

const pickup_sounds = [
    preload("res://package/sounds/pickup_1.wav"),
    preload("res://package/sounds/pickup_2.wav"),
    preload("res://package/sounds/pickup_3.wav"),
    preload("res://package/sounds/pickup_4.wav")
]

const moving_sounds = [
    [
        preload("res://package/sounds/moving_a_1.wav"),
        preload("res://package/sounds/moving_a_2.wav"),
    ], [
        preload("res://package/sounds/moving_b_1.wav"),
        preload("res://package/sounds/moving_b_2.wav"),
        preload("res://package/sounds/moving_b_3.wav"),
        preload("res://package/sounds/moving_b_4.wav"),
    ],[
        preload("res://package/sounds/moving_c_1.wav"),
        preload("res://package/sounds/moving_c_2.wav"),
        preload("res://package/sounds/moving_c_3.wav"),
        preload("res://package/sounds/moving_c_4.wav"),
        preload("res://package/sounds/moving_c_5.wav"),
        preload("res://package/sounds/moving_c_6.wav"),
    ]
]
var moving_sounds_idx: int


const personal_delivery_conglomerate_material = preload("res://package/materials/personal_delivery_conglomerate.tres")
const logistics_corp_material = preload("res://package/materials/logistics_corp.tres")
const ship_for_less_material = preload("res://package/materials/ship_for_less.tres")

class Address:
    var street_number: String
    var street: String
    var suburb: String
    var postcode: String
    var state: String = 'NSW'

    func _init(_street_number: String, _street: String, _suburb: String, _postcode: String):
        street_number = _street_number
        street = _street
        suburb = _suburb
        postcode = _postcode

    func _to_string():
        return '%s %s\n%s %s %s' % [street_number, street, suburb, postcode, state]

@export var shape := Shape.BOX:
    set(value):
        shape = value
        update_model()

@export var size := Size.MEDIUM:
    set(value):
        size = value
        update_model()

@export var company := Company.PERSONAL_DELIVERY_CONGLOMERATE:
    set(value):
        company = value
        update_model()

var first_name: String
var last_name: String

var address: Address

@onready var collision_shape := $CollisionShape3D
@onready var mesh := $MeshInstance3D

const FIRST_NAMES_FILE := "res://package/firstnames.txt"
const LAST_NAMES_FILE := "res://package/lastnames.txt"

func _ready():
    update_model()

func update_model():
    if collision_shape == null:
        return

    match shape:
        Shape.BOX:
            match size:
                Size.SMALL:
                    # TODO: weight doesn't necessarily correspond to size.
                    collision_shape.shape = box_small_shape
                    mesh.mesh = box_small_mesh.duplicate()
                    mass = 0.5
                Size.MEDIUM:
                    collision_shape.shape = box_medium_shape
                    mesh.mesh = box_medium_mesh.duplicate()
                    mass = 0.8
                Size.LARGE:
                    collision_shape.shape = box_large_shape
                    mesh.mesh = box_large_mesh.duplicate()
                    mass = 1.5
        Shape.TUBE:
            match size:
                Size.SMALL:
                    collision_shape.shape = tube_small_shape
                    mesh.mesh = tube_small_mesh.duplicate()
                    mass = 0.4
                Size.MEDIUM:
                    collision_shape.shape = tube_medium_shape
                    mesh.mesh = tube_medium_mesh.duplicate()
                    mass = 0.6
                Size.LARGE:
                    collision_shape.shape = tube_large_shape
                    mesh.mesh = tube_large_mesh.duplicate()
                    mass = .8

    match company:
        Company.PERSONAL_DELIVERY_CONGLOMERATE:
            mesh.mesh.surface_set_material(0, personal_delivery_conglomerate_material)
        Company.LOGISTICS_CORP:
            mesh.mesh.surface_set_material(0, logistics_corp_material)
        Company.SHIP_FOR_LESS:
            mesh.mesh.surface_set_material(0, ship_for_less_material)
    moving_sounds_idx = randi_range(0, moving_sounds.size()-1)

func randomize_attributes():
    shape = get_random_shape()
    size = get_random_size()
    company = get_random_company()
    first_name = get_random_first_name()
    last_name = get_random_last_name()
    address = get_random_address()

func _to_string():
    return 'Package{name: "%s %s"}' % [first_name, last_name]

func hover(state):
    if state:
        print('hovered over package: %s' % self)

static func get_random_shape():
    return Shape.values().pick_random()

static func get_random_size():
    return Size.values().pick_random()

static func get_random_company():
    return Company.values()[randi_range(0, Company.size()-1)]

static func get_random_first_name():
    var file := FileAccess.open(FIRST_NAMES_FILE, FileAccess.READ)
    var names = file.get_as_text().split('\n', false)
    return names[randi_range(0, names.size()-1)]

static func get_random_last_name():
    # TODO: come up with some actual last names
    var file := FileAccess.open(FIRST_NAMES_FILE, FileAccess.READ)
    var names = file.get_as_text().split('\n', false)
    return names[randi_range(0, names.size()-1)] + 'son'

static func get_random_address():
    # The post office would serve only a few suburbs / districts.
    # At first we can only include those suburbs.
    # Perhaps later it can be a game mechanic to redirect packages to other post offices.

    var file := FileAccess.open("res://package/addresses.json", FileAccess.READ)
    var data: Dictionary = JSON.parse_string(file.get_as_text())

    var suburb: String = data.keys().pick_random().capitalize()

    return Address.new(
        str(randi() % 99 + 1),
        data[suburb]["streets"].pick_random(),
        suburb,
        str(data[suburb]["postcode"]),
    )

func _integrate_forces(state):
    if (state.linear_velocity.length() > 0.5 \
        or state.angular_velocity.length() > 4*PI) \
        and not $Audio.playing:
        $Audio.stream = moving_sounds[moving_sounds_idx].pick_random()
        $Audio.play()

func _on_sleeping_state_changed():
    if not sleeping:
        $Audio.stream = pickup_sounds.pick_random()
        $Audio.play()
