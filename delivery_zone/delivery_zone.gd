extends Node3D

signal package_delivered(package: Package)

const Package = preload("res://package/package.gd")

@onready var delivery_area = $DeliveryArea
@onready var animation_player = $AnimationPlayer

func _on_delivery_area_body_entered(body: Node3D):
    update_screen(null)

func _on_delivery_area_body_exited(body: Node3D):
    update_screen(body)

func update_screen(ignore_body):
    var bodies = delivery_area.get_overlapping_bodies()
    if bodies.size() == 1 and bodies[0] != ignore_body:
        var package: Package = bodies[0]

        # TODO: check whether the package is right.

        animation_player.play("correct")
        package_delivered.emit(package)
