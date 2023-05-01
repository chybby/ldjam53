extends CharacterBody3D

var Package = preload("res://package/package.gd")

@export var walk_speed := 3.0
@export var sprint_speed := 6.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002
@export var held_item_move_strength := 150
@export var held_item_rotate_strength := 10

@onready var camera := $Camera
@onready var interact_ray := $Camera/InteractRay
@onready var held_item_marker := $Camera/HeldItemMarker

var hovered_object: Node = null
var held_object: RigidBody3D = null

var can_move = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event):
    if not can_move:
        return

    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        if Input.is_action_pressed("rotate_held_item") and held_object != null:
            var torque := Vector3(event.relative.y, event.relative.x, 0) * held_item_rotate_strength * mouse_sensitivity
            torque *= basis.transposed()
            held_object.apply_torque(torque)
        else:
            rotate_y(-event.relative.x * mouse_sensitivity)
            camera.rotate_x(-event.relative.y * mouse_sensitivity)
            camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
    elif event.is_action_pressed('interact'):
        if hovered_object and is_instance_valid(hovered_object):
            if hovered_object.has_method('interact'):
                hovered_object.interact()
            if hovered_object.is_in_group('pickup'):
                if held_object == null:
                    held_object = hovered_object
                    held_item_marker.global_position = held_object.global_position
                    held_object.linear_damp = 20
                    held_object.angular_damp = 10
                    held_object.set_inertia(Vector3.ONE * 0.01)
                    print('Holding %s' % held_object)
                    #hovered_object = null
    elif event.is_action_released('interact'):
        drop_object()
    elif event.is_action_pressed('move_held_item_away') and held_object != null:
        if held_item_marker.position.length() < 2.5:
            held_item_marker.position += held_item_marker.position.normalized() * 0.1
    elif event.is_action_pressed('move_held_item_towards') and held_object != null:
        if held_item_marker.position.length() > 1.5:
            held_item_marker.position -= held_item_marker.position.normalized() * 0.1

func drop_object():
    if held_object:
        held_object.linear_damp = 0
        held_object.angular_damp = 0
        held_object.set_inertia(Vector3.ZERO)
        print('Dropped %s' % held_object)
        held_object = null

func _process(delta):
    if not is_instance_valid(hovered_object):
        hovered_object = null

    if interact_ray.get_collider() != hovered_object:
        if hovered_object and is_instance_valid(hovered_object) and hovered_object.has_method('hover'):
            hovered_object.hover(false)
        hovered_object = interact_ray.get_collider()
        if hovered_object and hovered_object.has_method('hover'):
            hovered_object.hover(true)

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle Jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var speed = walk_speed
    if Input.is_action_pressed("sprint"):
        speed = sprint_speed

    # Get the input direction and handle the movement/deceleration.
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()

    # Drag held object.
    if held_object:
        var force_direction: Vector3 = held_item_marker.global_position - held_object.global_position
        held_object.apply_central_force(force_direction * held_item_move_strength)

func reset():
    rotation = Vector3.ZERO
    camera.rotation = Vector3.ZERO
    hovered_object = null
    held_object = null
