@tool
extends RigidBody3D

enum Shape {BOX, TUBE}
enum Size {SMALL, MEDIUM, LARGE}
enum Company {PERSONAL_DELIVERY_CONGLOMERATE, LOGISTICS_CORP, SHIP_FOR_LESS}

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
                    size_vector = Vector3(.2, .2, .2)
                    mass = 0.3
                Size.MEDIUM:
                    size_vector = Vector3(.4, .4, .4)
                    mass = 0.7
                Size.LARGE:
                    size_vector = Vector3(1, 1, 1)
                    mass = 2
            collision_shape.shape.size = size_vector
            mesh.mesh.size = size_vector
        Shape.TUBE:
            collision_shape.shape = CylinderShape3D.new()
            mesh.mesh = CylinderMesh.new()

            var height : float
            var radius: float
            match size:
                Size.SMALL:
                    height = 0.4
                    radius = 0.05
                    mass = 0.2
                Size.MEDIUM:
                    height = 0.5
                    radius = 0.1
                    mass = 0.5
                Size.LARGE:
                    height = 1.5
                    radius = 0.15
                    mass = 1
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
    return Company.values().pick_random()

static func get_random_first_name():
    var file := FileAccess.open(FIRST_NAMES_FILE, FileAccess.READ)
    var names = file.get_as_text().split('\n', false)
    return names[randi_range(0, names.size()-1)]

static func get_random_last_name():
    # TODO: come up with some actual last names
    var file := FileAccess.open(FIRST_NAMES_FILE, FileAccess.READ)
    var names = file.get_as_text().split('\n', false)
    return names[randi_range(0, names.size()-1)] + 'son'
