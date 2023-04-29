extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002
@export var held_item_strength := 150

@onready var camera := $Camera
@onready var interact_ray := $Camera/InteractRay
@onready var held_item_marker := $Camera/HeldItemMarker

var hovered_object: Node = null
var held_object: RigidBody3D = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var Package = preload("res://package/package.gd")

func _unhandled_input(event):
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotate_x(-event.relative.y * mouse_sensitivity)
        camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
    elif event.is_action_pressed('interact'):
        if hovered_object:
            if hovered_object.has_method('interact'):
                hovered_object.interact()
            if hovered_object.is_in_group('pickup'):
                if held_object == null:
                    held_object = hovered_object
                    held_object.linear_damp = 20
                    held_object.angular_damp = 10
                    print('Holding %s' % held_object)
                    hovered_object = null
    elif event.is_action_released('interact'):
        if held_object:
            held_object.linear_damp = 0
            held_object.angular_damp = 0
            print('Dropped %s' % held_object)
            held_object = null

func _process(delta):
    if interact_ray.get_collider() != hovered_object:
        if hovered_object and hovered_object.has_method('hover'):
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

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
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
        held_object.apply_central_force(force_direction * held_item_strength)

