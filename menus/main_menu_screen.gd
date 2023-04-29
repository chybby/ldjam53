extends Control

signal game_started

func _on_start_button_pressed():
    game_started.emit()
