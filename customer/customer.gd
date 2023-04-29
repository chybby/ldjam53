extends CharacterBody3D

@export var speed = 50

@onready var serving_point = get_node("../Level/CustomerServingPoint")
@onready var exit_area = get_node("../Level/CustomerExitArea")

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
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    else: 
        dir = dir.normalized()
        velocity.x = dir.x * speed * delta
        velocity.z = dir.z * speed * delta

    # TODO: this is buggy (doesn't even rotate to the serving point fully) and janky at spawn
    rotation.y = position.signed_angle_to(p, Vector3.UP) - PI

    move_and_slide()


func _on_area_3d_body_entered(body):
    if body.collision_layer == 1 << 1:
        print("satisfied")
        is_satisfied = true
    
func _on_area_3d_area_entered(area):
    print(area.collision_layer)
    if area.collision_layer == 1 << 3 and is_satisfied:
        queue_free()
