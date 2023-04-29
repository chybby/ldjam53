extends Control

signal game_started

func _on_start_button_pressed():
    emit_signal("game_started")
