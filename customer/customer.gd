extends CharacterBody3D

@export var speed = 50

@onready var serving_point = get_node("/root/Main/World/DeliveryZone")
@onready var exit_area = get_node("../Level/CustomerExitArea")
@onready var target_rot = Node3D.new()

var is_satisfied = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    var p = serving_point.position
    if is_satisfied:
        p = exit_area.position
    var dir = p - position
    if dir.length() < 1:
        # TODO: here they should show their ID card and be ready to receive a package
        # maybe better to code elsewhere in an area interaction
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    else:
        dir = dir.normalized()
        velocity.x = dir.x * speed * delta
        velocity.z = dir.z * speed * delta

    # TODO: I would LOVE to make them smoothly rotate, especially when satisfied
    # and switching to going to the exit, but I'm too dumb for that right now
    look_at(p, Vector3.UP)

    move_and_slide()


func _on_area_3d_body_entered(body):
    if body.collision_layer == 1 << 1:
        print("satisfied")
        is_satisfied = true

func _on_area_3d_area_entered(area):
    print(area.collision_layer)
    if area.collision_layer == 1 << 4 and is_satisfied:
        queue_free()
