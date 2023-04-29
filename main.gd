extends Node

@onready var gui := $GUI
@onready var world := $World

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
    if event.is_action_pressed("pause"):
        gui.show_pause_screen()
        get_tree().paused = true

func _on_gui_unpaused():
    get_tree().paused = false
