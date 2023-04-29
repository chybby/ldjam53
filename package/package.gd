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

@onready var collision_shape := $CollisionShape3D
@onready var mesh := $MeshInstance3D

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
                    size_vector = Vector3(.2, .2, .2)
                Size.MEDIUM:
                    size_vector = Vector3(.4, .4, .4)
                Size.LARGE:
                    size_vector = Vector3(1, 1, 1)
            collision_shape.shape.size = size_vector
            mesh.mesh.size = size_vector
        Shape.TUBE:
            collision_shape.shape = CylinderShape3D.new()
            mesh.mesh = CylinderMesh.new()

            var height : float
            var radius: float
            match size:
                Size.SMALL:
                    height = 0.3
                    radius = 0.1
                Size.MEDIUM:
                    height = 0.5
                    radius = 0.2
                Size.LARGE:
                    height = 0.8
                    radius = 0.3
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

static func get_random_shape():
    return Shape.values()[randi_range(0, Shape.size()-1)]

static func get_random_size():
    return Size.values()[randi_range(0, Size.size()-1)]

static func get_random_company():
    return Company.values()[randi_range(0, Company.size()-1)]

static func get_random_address():
    # The post office would serve only a few suburbs / districts.
    # At first we can only include those suburbs.
    # Perhaps later it can be a game mechanic to redirect packages to other post offices.

    var d := {}
    d["street_number"] = randi() % 99 + 1

    var file := FileAccess.open("res://package/addresses.json", FileAccess.READ)
    var data: Dictionary = JSON.parse_string(file.get_as_text())

    var i := randi() % data.keys().size()
    var suburb: String = data.keys()[i].capitalize()
    d["suburb"] = suburb
    d["postcode"] = data[suburb]["postcode"]
    i = randi() % data[suburb]["streets"].size()
    d["street"] = data[suburb]["streets"][i]

    # {street_number} {street}
    # {suburb} NSW {postcode}
    return "{street_number} {street}\n{suburb} NSW {postcode}".format(d)
    
