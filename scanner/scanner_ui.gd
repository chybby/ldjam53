extends Control

@onready var scan_something_label := $Panel/ScanSomethingLabel
@onready var name_label := $Panel/NameLabel
@onready var address_label := $Panel/AddressLabel

func display_name_address(name: String, address: String):
    name_label.visible = true
    name_label.text = name
    address_label.visible = true
    address_label.text = address
    scan_something_label.visible = false

func clear_display():
    name_label.visible = false
    address_label.visible = false
    scan_something_label.visible = true
