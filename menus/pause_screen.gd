extends Control

signal closed

func _input(event):
    if event.is_action_pressed("pause"):
        emit_signal("closed")
        get_viewport().set_input_as_handled()

func _on_close_button_pressed():
    emit_signal("closed")
