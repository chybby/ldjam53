extends Control

signal unpaused
signal game_started
signal volume_changed(volume: float)
signal mouse_sensitivity_changed(mouse_sensitivity: float)

@onready var main_menu_screen := $MainMenuScreen
@onready var pause_screen := $PauseScreen
@onready var hud := $HUD

func _ready():
    main_menu_screen.set_process_input(true)
    pause_screen.set_process_input(false)
    hud.set_process_input(false)

func show_pause_screen():
    if not pause_screen.visible:
        pause_screen.visible = true
        pause_screen.set_process_input(true)
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        hud.visible = false

func _on_pause_screen_closed():
    pause_screen.visible = false
    pause_screen.set_process_input(false)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    hud.visible = true
    emit_signal("unpaused")

func _on_main_menu_screen_game_started():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    main_menu_screen.set_process_input(false)
    main_menu_screen.visible = false
    hud.visible = true
    emit_signal("game_started")

func set_mouse_sensitivity(mouse_sensitivity: float):
    pause_screen.set_mouse_sensitivity(mouse_sensitivity)

func _on_pause_screen_mouse_sensitivity_changed(mouse_sensitivity: float):
    emit_signal("mouse_sensitivity_changed", mouse_sensitivity)

func _on_pause_screen_volume_changed(volume: float):
    emit_signal("volume_changed", volume)
