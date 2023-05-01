extends Node

const GUI = preload("res://menus/gui.gd")
const Package = preload("res://package/package.gd")
const Phone = preload("res://level/phone.gd")
const StoreOpener = preload("res://store_opener/store_opener.gd")

@onready var gui := $GUI
@onready var world := $World
@onready var player := $World/Player

var can_pause := false

const SKIP_MAIN_MENU := false
const SKIP_TUTORIAL := false

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
        _on_world_day_ended(10, 59)

func _process(delta):
    if player.held_object != null:
        gui.set_cursor(GUI.Cursor.CLOSED_HAND, 'Rotate')
    elif is_instance_valid(player.hovered_object) and player.hovered_object is Package:
        gui.set_cursor(GUI.Cursor.OPEN_HAND, 'Grab')
    elif is_instance_valid(player.hovered_object) and player.hovered_object is Phone and player.hovered_object.is_ringing():
        gui.set_cursor(GUI.Cursor.OPEN_HAND, 'Pick Up')
    elif is_instance_valid(player.hovered_object) and player.hovered_object is StoreOpener and not player.hovered_object.is_store_open():
        gui.set_cursor(GUI.Cursor.OPEN_HAND, 'Open Store')
    else:
        gui.set_cursor(GUI.Cursor.DOT, '')

func _on_gui_unpaused():
    get_tree().paused = false

func start_game():
    can_pause = true
    get_tree().paused = false
    world.start_day(day, SKIP_TUTORIAL)

func _on_gui_game_started():
    start_game()

func _on_gui_mouse_sensitivity_changed(mouse_sensitivity):
    player.mouse_sensitivity = mouse_sensitivity

func _on_gui_volume_changed(volume: float):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

func _on_world_day_ended(packages: int, seconds: int):
    await gui.fade_out()
    gui.show_game_over_screen(packages, seconds)
    await gui.game_over_screen_closed
    day += 1
    world.start_day(day)
    await gui.fade_in()

var day_0_tutorial : Array[String] = [
    "Hello?",
    "Ah hello! Welcome to your first day at Personal Delivery Conglomerate™!",
    "Sorry I couldn't be there in person today, I prefer to work from home most days.",
    "I can't really show you the ropes too well over the phone but I'm sure you'll work things out.",
    "You just need to take the packages that come in on the conveyor and store them on the shelves in the back.",
    "Try to keep it organised back there, store them by size or shape or something.",
    "You could also store them by delivery company based on the logo on the box.",
    "Our logo is the blue man with the green hat.",
    "This centre also receives packages on behalf of Logistics Corp and Ship 4 Less.",
    "Once all the packages have come in, flip the switch to open the store.",
    "Customers will start coming around to collect.",
    "Make sure to check their ID to find out their name and address.",
    "You can scan packages at the blue scanning machine in the back to see who they're for.",
    "I'll give you a bigger bonus if you can give customers the right package quickly...",
    "so that's why getting organised at the start of the day is so important.",
    "Anyway, I've chatted your ear off enough. Get to work.",
    "And remember, \"With Personal Delivery Conglomerate™, it's always personal®\" *click*",
]

var day_1_tutorial : Array[String] = [
    "Hello again!",
    "More of the same today.",
    "It was a busy day, there'll be a few more packages so you'll really have to bring your organisational A-game.",
    "Anyway, I'm sure you're itching to get started. Get to work.",
    "And remember, \"With Personal Delivery Conglomerate™, it's always personal®\" *click*",
]

var day_2_tutorial : Array[String] = [
    "Hello once more!",
    "Good job delivering all the packages yesterday, you did an adequate job.",
    "Listen, there may be a few more packages today...",
    "Some of our delivery drivers heard that I had started working from home and followed suit.",
    "And by some I mean all.",
    "Anyway, I'm sure it's nothing you can't handle :). Get to work.",
    "And remember, \"With Personal Delivery Conglomerate™, it's always personal®\" *click*",
]

func _on_world_phone_call_started():
    match day:
        0:
            gui.show_call(day_0_tutorial)
        1:
            gui.show_call(day_1_tutorial)
        2:
            gui.show_call(day_2_tutorial)
    await gui.call_ended
    world.finish_call()
