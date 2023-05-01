extends Control

@onready var name_label = $Panel/Name
@onready var address_label = $Panel/Address

func set_contents(customer_name: String, address: String):
    name_label.text = customer_name
    address_label.text = address
