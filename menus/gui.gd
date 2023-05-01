extends Control

signal unpaused
signal game_started
signal volume_changed(volume: float)
signal mouse_sensitivity_changed(mouse_sensitivity: float)
signal call_ended
signal game_over_screen_closed

@onready var main_menu_screen := $MainMenuScreen
@onready var pause_screen := $PauseScreen
@onready var game_over_screen := $GameOverScreen
@onready var hud := $HUD

var call_ongoing = false

enum Cursor {DOT, OPEN_HAND, CLOSED_HAND}

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

func show_game_over_screen(packages: int, seconds: int):
    game_over_screen.show_stats(packages, seconds)
    game_over_screen.visible = true
    game_over_screen.set_process_input(true)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    hud.visible = false
    await game_over_screen.dismissed
    game_over_screen.visible = false
    game_over_screen.set_process_input(false)
    hud.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    game_over_screen_closed.emit()

func set_cursor(cursor: Cursor, instructions: String):
    hud.set_cursor(cursor, instructions)

func fade_out():
    return hud.fade_out()

func fade_in():
    return hud.fade_in()

func _on_pause_screen_closed():
    pause_screen.visible = false
    pause_screen.set_process_input(false)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    hud.visible = true
    unpaused.emit()

func _on_main_menu_screen_game_started():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    main_menu_screen.set_process_input(false)
    main_menu_screen.visible = false
    hud.visible = true
    game_started.emit()

func set_mouse_sensitivity(mouse_sensitivity: float):
    pause_screen.set_mouse_sensitivity(mouse_sensitivity)

func _on_pause_screen_mouse_sensitivity_changed(mouse_sensitivity: float):
    mouse_sensitivity_changed.emit(mouse_sensitivity)

func _on_pause_screen_volume_changed(volume: float):
    volume_changed.emit(volume)

func show_call(dialog: Array[String]):
    call_ongoing = true
    for line in dialog:
        hud.show_dialog(line)
        await hud.next_dialog
    call_ended.emit()
