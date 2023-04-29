extends Control

signal closed
signal volume_changed(volume: float)
signal mouse_sensitivity_changed(mouse_sensitivity: float)

@onready var mouse_sensitivity_slider := $Panel/Sliders/Sliders/MouseSensitivitySlider

func _input(event):
    if event.is_action_pressed("pause"):
        emit_signal("closed")
        get_viewport().set_input_as_handled()

func _on_close_button_pressed():
    emit_signal("closed")

func _on_volume_slider_value_changed(volume: float):
    emit_signal("volume_changed", volume)

func set_mouse_sensitivity(mouse_sensitivity: float):
    mouse_sensitivity_slider.value = mouse_sensitivity

func _on_mouse_sensitivity_slider_value_changed(mouse_sensitivity: float):
    emit_signal("mouse_sensitivity_changed", mouse_sensitivity)
