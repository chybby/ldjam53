extends Node3D

signal call_started

@onready var animation_player := $AnimationPlayer

var ringing := false

func start_ringing():
    ringing = true
    # TODO: turn on ringing sound

func hover(state):
    if state:
        print('hovered over phone')

func interact():
    if ringing:
        ringing = false
        animation_player.play("pick_up")
        # TODO: stop ringing sound
        call_started.emit()

func finish_call():
    animation_player.play_backwards("pick_up")

func is_ringing():
    return ringing
