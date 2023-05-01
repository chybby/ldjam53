extends CharacterBody3D

const Package = preload("res://package/package.gd")
const ID = preload("res://customer/id.gd")
const IDScene = preload("res://customer/id.tscn")

@export var speed = 100
@export var follow_distance = 1

@onready var speech_bubble = $Speech
@onready var speech_bubble_ui = $Viewport/SpeechBubble

var is_satisfied = false
var needed_package: Package
var id: ID = null
var speech := ""

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target_node: Node3D
var exit_area: Vector3

func setup(_target_node, _exit_area, package: Package):
    target_node = _target_node
    exit_area = _exit_area
    needed_package = package

    id = IDScene.instantiate()
    id.from_package(package)

    speech = generate_speech()

func description_from_size(size):
    match size:
        Package.Size.SMALL:
            var descriptions = [
                "a small",
                "a tiny",
            ]
            return descriptions.pick_random()
        Package.Size.MEDIUM:
            var descriptions = [
                "a medium",
                "an average-sized",
                "a neither big nor small",
            ]
            return descriptions.pick_random()
        Package.Size.LARGE:
            var descriptions = [
                "a large",
                "a huge",
                "a massive",
            ]
            return descriptions.pick_random()

func description_from_shape(shape):
    match shape:
        Package.Shape.BOX:
            var descriptions = [
                "a package in a box",
                "a box",
                "a box full of things from my exes house",
            ]
            return descriptions.pick_random()
        Package.Shape.TUBE:
            var descriptions = [
                "a tube-shaped package",
                "a poster for my fave K-pop group",
                "my university diploma. They better not have rolled it up",
                "a tasty dried sausage from Poland",
            ]
            return descriptions.pick_random()

func description_from_company(company):
    match company:
        Package.Company.PERSONAL_DELIVERY_CONGLOMERATE:
            var descriptions = [
                "Personal Delivery Conglomerate",
                "PDC",
                "People Deliver Company or something",
            ]
            return descriptions.pick_random()
        Package.Company.SHIP_FOR_LESS:
            var descriptions = [
                "Ship For Less",
                "that delivery company for cheapskates",
            ]
            return descriptions.pick_random()
        Package.Company.LOGISTICS_CORP:
            var descriptions = [
                "Logistics Corp",
                "that company with the green truck logo",
            ]
            return descriptions.pick_random()

func generate_speech():
    match randi() % 4:
        0:
            # Say something about package size.
            var size = needed_package.size
            var sentences = [
                "I'm picking up %s package.",
                "I've got %s package to pick up.",
                "My mum sent me to pick up %s package.",
                "My dad sent me %s package. I was home all day but it came here.",
                "Hey, I'm here to pick up %s delivery.",
                "I've heard you've got %s package for me."
            ]
            return sentences.pick_random() % description_from_size(size)
        1:
            # Say something about package shape.
            var shape = needed_package.shape
            var sentences = [
                "I'm picking up %s.",
                "My dad sent me %s. I was home all day but it came here.",
                "Hey, I'm here to pick up %s.",
                "My mum sent me here to pick up %s.",
                "I got a delivery notice. It should be %s",
            ]
            return sentences.pick_random() % description_from_shape(shape)
        2:
            # Say something about delivery company.
            var delivery_company = needed_package.company
            var sentences = [
                "I'm picking up a package from %s.",
                "I got a delivery notice from %s.",
                "I sent a package with %s but I forgot to pay for it so they sent it back here.",
                "I was supposed to get a package from %s today but they didn't even bother trying to deliver it and just sent it straight here.",
                "Yo, apparently I have a package from %s waiting for me here.",
            ]
            return sentences.pick_random() % description_from_company(delivery_company)
        3:
            # Say nothing useful.
            var sentences = [
                "I don't usually get packages, this is so exciting!",
                "I got places to be so you better give me my package quick.",
            ]
            return sentences.pick_random()

func speak():
    speech_bubble_ui.play_text(speech)
    speech_bubble.visible = true

func stop_speaking():
    speech_bubble.visible = false

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

func accept_package():
    is_satisfied = true
    stop_speaking()

func _on_area_3d_area_entered(area):
    if area.collision_layer == 1 << 4 and is_satisfied:
        var tween = get_tree().create_tween()
        tween.tween_property($Character, "modulate", Color(1,1,1,0), 1)
        tween.tween_callback(queue_free)
