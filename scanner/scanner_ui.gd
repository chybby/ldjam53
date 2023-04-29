extends Control

@onready var name_label := $Panel/NameLabel
@onready var address_label := $Panel/AddressLabel

func set_name_label(name: String):
    name_label.text = name

func set_address_label(address: String):
    address_label.text = address
