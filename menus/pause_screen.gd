extends Control

signal closed
signal volume_changed(volume: float)
signal mouse_sensitivity_changed(mouse_sensitivity: float)

@onready var mouse_sensitivity_slider := $Panel/Sliders/Sliders/MouseSensitivitySlider

func _input(event):
    if event.is_action_pressed("pause"):
        closed.emit()
        get_viewport().set_input_as_handled()

func _on_close_button_pressed():
    closed.emit()

func _on_volume_slider_value_changed(volume: float):
    volume_changed.emit(volume)

func set_mouse_sensitivity(mouse_sensitivity: float):
    mouse_sensitivity_slider.value = mouse_sensitivity

func _on_mouse_sensitivity_slider_value_changed(mouse_sensitivity: float):
    mouse_sensitivity_changed.emit(mouse_sensitivity)
