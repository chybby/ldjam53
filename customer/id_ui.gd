extends Control

@onready var name_label = $Panel/Name
@onready var address_label = $Panel/Address

func set_contents(name: String, address: String):
    name_label.text = name
    address_label.text = address
