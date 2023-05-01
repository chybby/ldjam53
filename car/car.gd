extends Node3D

var speed = 20
var flip = false

const colours = [
        preload("res://car/red.tres"),
        preload("res://car/blue.tres"),
        preload("res://car/yellow.tres")
]

@onready var box_mesh = $Box
@onready var prism_mesh = $Prism

func _ready():
    var mat = colours.pick_random()
    box_mesh.mesh = box_mesh.mesh.duplicate()
    box_mesh.mesh.surface_set_material(0, mat)
    prism_mesh.mesh = prism_mesh.mesh.duplicate()
    prism_mesh.mesh.surface_set_material(0, mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if flip:
        position.x -= speed*delta
    else:
        position.x += speed*delta

func _on_self_death_timeout():
    queue_free()
