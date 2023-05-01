extends Node3D

const Package = preload("res://package/package.gd")

@onready var id_ui = $Viewport/IDUI

var package: Package = null

func from_package(_package: Package):
    package = _package

func _ready():
    id_ui.set_contents(
        package.first_name + "\n" + package.last_name,
        package.address._to_string()
    )
