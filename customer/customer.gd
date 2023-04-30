extends CharacterBody3D

const Package = preload("res://package/package.gd")

@export var speed = 100
@export var follow_distance = 1

var is_satisfied = false
var needed_package: Package

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target_node: Node3D
var exit_area: Vector3

func setup(_target_node, _exit_area):
    target_node = _target_node
    exit_area = _exit_area

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    var p = target_node.position
    if is_satisfied:
        p = exit_area
    var dir = p - position
    var length = dir.length()
    dir = dir.normalized()

    if length > follow_distance:
        velocity.x = dir.x * speed * delta
        velocity.z = dir.z * speed * delta
    if length <= follow_distance:
        velocity.x =  move_toward(velocity.x, 0, delta)
        velocity.z =  move_toward(velocity.z, 0, delta)

    move_and_slide()

func _on_area_3d_area_entered(area):
    if area.collision_layer == 1 << 4 and is_satisfied:
        var tween = get_tree().create_tween()
        tween.tween_property($Character, "modulate", Color(1,1,1,0), 1)
        tween.tween_callback(queue_free)
