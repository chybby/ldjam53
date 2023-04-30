extends Control

@onready var label = $Panel/Label

func set_label(name: String):
    label.text = name
