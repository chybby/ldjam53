@tool
extends RigidBody3D

enum Shape {BOX, TUBE}
enum Size {SMALL, MEDIUM, LARGE}
enum Company {PERSONAL_DELIVERY_CONGLOMERATE, LOGISTICS_CORP, SHIP_FOR_LESS}

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
            collision_shape.shape = BoxShape3D.new()
            mesh.mesh = BoxMesh.new()

            var size_vector : Vector3
            match size:
                Size.SMALL:
                    # TODO: weight doesn't necessarily correspond to size.
                    size_vector = Vector3(.2, .3, .4)
                    mass = 0.5
                Size.MEDIUM:
                    size_vector = Vector3(.5, .4, .6)
                    mass = 0.8
                Size.LARGE:
                    size_vector = Vector3(.8, .7, 1.1)
                    mass = 1.5
            collision_shape.shape.size = size_vector
            mesh.mesh.size = size_vector
        Shape.TUBE:
            collision_shape.shape = CylinderShape3D.new()
            mesh.mesh = CylinderMesh.new()

            var height : float
            var radius: float
            match size:
                Size.SMALL:
                    height = 0.6
                    radius = 0.08
                    mass = 0.4
                Size.MEDIUM:
                    height = 1
                    radius = 0.1
                    mass = 0.6
                Size.LARGE:
                    height = 1.6
                    radius = 0.12
                    mass = .8
            collision_shape.shape.height = height
            collision_shape.shape.radius = radius
            mesh.mesh.height = height
            mesh.mesh.bottom_radius = radius
            mesh.mesh.top_radius = radius

    # TODO: Create a set of nicer materials that we can just swap around.
    mesh.mesh.material = StandardMaterial3D.new()
    match company:
        Company.PERSONAL_DELIVERY_CONGLOMERATE:
            mesh.mesh.material.albedo_color = Color(0.83203125, 0.70602869987488, 0.18749018013477)
        Company.LOGISTICS_CORP:
            mesh.mesh.material.albedo_color = Color(0.46042990684509, 0.55753999948502, 0.90625)
        Company.SHIP_FOR_LESS:
            mesh.mesh.material.albedo_color = Color(0.78382098674774, 1, 0.52286148071289)

func randomize():
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

