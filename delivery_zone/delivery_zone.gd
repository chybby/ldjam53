extends Node3D

signal package_delivered(package: Package)

const Package = preload("res://package/package.gd")
const World = preload("res://world.gd")
const Customer = preload("res://customer/customer.gd")
const ID = preload("res://customer/id.gd")

@onready var world: World = get_parent()
@onready var delivery_area = $DeliveryArea
@onready var waiting_area = $WaitingArea
@onready var id_spawn_point = $IDSpawnPoint
@onready var animation_player = $AnimationPlayer

var serving_customer: Customer = null
var id: ID = null

func _on_delivery_area_body_entered(body: Node3D):
    update_screen(null)

func _on_delivery_area_body_exited(body: Node3D):
    update_screen(body)

func update_screen(ignore_body):
    var bodies = delivery_area.get_overlapping_bodies()
    if bodies.size() == 1 and bodies[0] != ignore_body:
        var package: Package = bodies[0]

        if serving_customer == null:
            return
        if package.name == serving_customer.needed_package.name:
            animation_player.play("correct")
            # TODO: show customer holding package?
            world.customer_queue[0].accept_package()
            world.customer_queue.pop_front()
            serving_customer = null
            remove_child(id)
            id = null

            # Go through the queue setting new follow targets.
            if not world.customer_queue.is_empty():
                world.customer_queue[0].target_node = self
            for i in world.customer_queue.size() - 1:
                world.customer_queue[i+1].target_node = world.customer_queue[i]

            # See if next customer already in area.
            for customer in delivery_area.get_overlapping_bodies():
                if not world.customer_queue.is_empty() and customer == world.customer_queue[0]:
                    display_id_for_customer(customer)
                    serving_customer = customer

            package_delivered.emit(package)
        else:
            animation_player.play('incorrect')

func display_id_for_customer(customer: Customer):
    id = customer.id
    add_child(id)
    id.position = id_spawn_point.position
    customer.speak()

func _on_waiting_area_body_entered(body: Node3D):
    if body == world.customer_queue[0]:
        serving_customer = body
        display_id_for_customer(body)
