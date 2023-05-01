extends Control

@onready var speech_label := $PanelContainer/Speech
@onready var animation_player := $AnimationPlayer
@onready var speech_sound_player = $SpeechSound

var speech_sounds = [
    preload("res://customer/hello_1.wav"),
    preload("res://customer/hello_2.wav"),
    preload("res://customer/hello_3.wav"),
]

func play_text(text: String):
    speech_label.text = text
    animation_player.play("speech")
    speech_sound_player.stream = speech_sounds.pick_random()
    speech_sound_player.play()
