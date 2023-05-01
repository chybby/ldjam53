extends StaticBody3D

signal store_opened

@onready var animation_player = $AnimationPlayer

var store_open = false

func hover(state):
    if state:
        print('hovered over store opener')

func interact():
    if not store_open:
        store_open = true
        animation_player.play("open")
        store_opened.emit()

func is_store_open():
    return store_open