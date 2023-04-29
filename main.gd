extends Node

@onready var gui := $GUI
@onready var world := $World

var can_pause := false

const SKIP_MAIN_MENU := true

func _ready():
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if SKIP_MAIN_MENU:
        gui._on_main_menu_screen_game_started()

func _input(event):
    if event.is_action_pressed("pause") and can_pause:
        gui.show_pause_screen()
        get_tree().paused = true

func _on_gui_unpaused():
    get_tree().paused = false

func start_game():
    can_pause = true
    get_tree().paused = false

func _on_gui_game_started():
    start_game()
