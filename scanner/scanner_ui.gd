extends Control

@onready var name_label := $Panel/Name

func set_name_label(name: String):
    name_label.text = name
