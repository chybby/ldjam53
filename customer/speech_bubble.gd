extends Control

@onready var speech_label := $PanelContainer/Speech
@onready var animation_player := $AnimationPlayer

func play_text(text: String):
    speech_label.text = text
    animation_player.play("speech")
