extends Control

signal unpaused
signal game_started

@onready var main_menu_screen := $MainMenuScreen
@onready var pause_screen := $PauseScreen
@onready var cursor := $Cursor

func _ready():
    main_menu_screen.set_process_input(true)
    pause_screen.set_process_input(false)

func show_pause_screen():
    if not pause_screen.visible:
        pause_screen.visible = true
        pause_screen.set_process_input(true)
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        cursor.visible = false

func _on_pause_screen_closed():
    pause_screen.visible = false
    pause_screen.set_process_input(false)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    cursor.visible = true
    emit_signal("unpaused")

func _on_main_menu_screen_game_started():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    main_menu_screen.set_process_input(false)
    main_menu_screen.visible = false
    cursor.visible = true
    emit_signal("game_started")
