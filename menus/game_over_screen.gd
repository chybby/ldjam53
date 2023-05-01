extends Control

signal dismissed

@onready var label = $Label

func show_stats(packages: int, seconds: int):
    label.text = "You delivered %d packages in %d:%02d!" % [packages, seconds/60, seconds%60]

func _on_button_pressed():
    dismissed.emit()
