extends Node3D

signal package_delivered(package: Package)

const Package = preload("res://package/package.gd")
const World = preload("res://world.gd")
const Customer = preload("res://customer/customer.gd")

@onready var world: World = get_parent()
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

        if world.customer_queue.is_empty():
            return
        if package.name == world.customer_queue[0].needed_package.name:
            animation_player.play("correct")
            world.customer_queue[0].is_satisfied = true
            world.customer_queue.pop_front()
            if not world.customer_queue.is_empty():
                world.customer_queue[0].target_node = self
            for i in world.customer_queue.size() - 1:
                world.customer_queue[i+1].target_node = world.customer_queue[i]

            var id = world.id_queue.pop_front()
            id.queue_free()
            if not world.id_queue.is_empty():
                world.id_queue[0].visible = true
            package_delivered.emit(package)
        else:
            animation_player.play('incorrect')


func _on_waiting_area_body_entered(body:Node3D):
    if not world.id_queue.is_empty():
        world.id_queue[0].visible = true
