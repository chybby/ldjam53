extends Node3D

signal package_delivered(package: Package)

const Package = preload("res://package/package.gd")
const Customer = preload("res://customer/customer.gd")
const IDScene = preload("res://customer/id.tscn")
const IDUIScene = preload("res://customer/id_ui.tscn")

var id_queue = []
var customer_queue = []
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

        if customer_queue.is_empty():
            return
        if package.name == customer_queue[0].needed_package.name:
            animation_player.play("correct")
            customer_queue[0].is_satisfied = true
            customer_queue.pop_front()

            var id = id_queue.pop_front()
            id.queue_free()
            if not id_queue.is_empty():
                id_queue[0].visible = true
            package_delivered.emit(package)


func _on_waiting_area_body_entered(body:Node3D):
    var customer: Customer = body
    var id := IDScene.instantiate()
    id.position = $IDSpawnPoint.position
    id.visible = false
    add_child(id)
    var id_ui := id.get_node("SubViewport/IDUI")
    id_ui.set_label(customer.needed_package.first_name + " " + customer.needed_package.last_name
    + "\n" + customer.needed_package.address._to_string())

    if id_queue.is_empty():
        id.visible = true
    customer_queue.push_back(customer)
    id_queue.push_back(id)
