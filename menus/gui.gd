extends Control

signal unpaused

@onready var main_menu_screen := $MainMenuScreen
@onready var pause_screen := $PauseScreen

func _ready():
    main_menu_screen.set_process_input(false)
    pause_screen.set_process_input(false)

func show_pause_screen():
    if not pause_screen.visible:
        pause_screen.visible = true
        pause_screen.set_process_input(true)
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_pause_screen_closed():
    pause_screen.visible = false
    pause_screen.set_process_input(false)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    emit_signal("unpaused")
