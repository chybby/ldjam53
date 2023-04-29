extends Control

@onready
var label : Label = $Panel/Label

func _on_Button_pressed() -> void:
    label.text = "You pressed the button!"
