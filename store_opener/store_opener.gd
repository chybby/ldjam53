extends StaticBody3D

signal store_opened

@onready var animation_player = $AnimationPlayer

var store_open = false
var openable = false

func hover(state):
    if state:
        print('hovered over store opener')

func interact():
    if not store_open and openable:
        store_open = true
        openable = false
        animation_player.play("open")
        store_opened.emit()

func is_store_open():
    return store_open

func can_open_store():
    return not store_open and openable

func reset():
    store_open = false
    openable = false
    animation_player.play("RESET")

func _on_world_all_packages_spawned():
    openable = true
