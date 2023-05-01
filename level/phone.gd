extends Node3D

signal call_started

@onready var animation_player := $AnimationPlayer
@onready var audio_player := $Audio

var phone_pickup_sound = preload("res://level/phone_pickup.wav")
var phone_hangup_sound = preload("res://level/phone_hangup.wav")
var phone_ringing_sound = preload("res://level/phone_ringing.wav")

var ringing := false

func start_ringing():
    ringing = true
    audio_player.stream = phone_ringing_sound
    audio_player.play()

func hover(state):
    if state:
        print('hovered over phone')

func interact():
    if ringing:
        ringing = false
        animation_player.play("pick_up")
        audio_player.stop()
        audio_player.stream = phone_pickup_sound
        audio_player.play()
        call_started.emit()

func finish_call():
    animation_player.play_backwards("pick_up")
    audio_player.stream = phone_hangup_sound
    audio_player.play()

func is_ringing():
    return ringing
