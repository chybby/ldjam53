extends Node

const GUI = preload("res://menus/gui.gd")

@onready var gui := $GUI
@onready var world := $World
@onready var player := $World/Player

var can_pause := false

const SKIP_MAIN_MENU := false

var day = 0

func _ready():
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    gui.set_mouse_sensitivity(player.mouse_sensitivity)

    if SKIP_MAIN_MENU:
        gui._on_main_menu_screen_game_started()

func _input(event):
    if event.is_action_pressed("pause") and can_pause:
        gui.show_pause_screen()
        get_tree().paused = true
    elif event.is_action_pressed("skip_day"):
        _on_world_day_ended()

func _process(delta):
    if player.held_object != null:
        gui.set_cursor(GUI.Cursor.CLOSED_HAND)
    elif player.hovered_object != null:
        gui.set_cursor(GUI.Cursor.OPEN_HAND)
    else:
        gui.set_cursor(GUI.Cursor.DOT)

func _on_gui_unpaused():
    get_tree().paused = false

func start_game():
    can_pause = true
    get_tree().paused = false
    world.start_day(day)

func _on_gui_game_started():
    start_game()

func _on_gui_mouse_sensitivity_changed(mouse_sensitivity):
    player.mouse_sensitivity = mouse_sensitivity

func _on_gui_volume_changed(volume: float):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

func _on_world_day_ended():
    await gui.fade_out()
    day += 1
    world.start_day(day)
    await gui.fade_in()
