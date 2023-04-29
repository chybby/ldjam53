extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("pause"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
