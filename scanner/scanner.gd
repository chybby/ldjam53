extends Node3D

const Package = preload("res://package/package.gd")

@onready var scanner_ui = $Viewport/ScannerUI
@onready var scan_area = $ScanArea
@onready var animation_player = $AnimationPlayer

func _on_scan_area_body_entered(body: Node3D):
    update_screen()

func _on_scan_area_body_exited(body: Node3D):
    update_screen()

func update_screen():
    var bodies = scan_area.get_overlapping_bodies()
    if bodies.size() == 1:
        var package: Package = bodies[0]
        scanner_ui.set_name_label(package.first_name + ' ' + package.last_name)
        scanner_ui.set_address_label(str(package.address))
        animation_player.play("scan_light")
    else:
        reset()

func reset():
    scanner_ui.set_name_label('Scan something')
    scanner_ui.set_address_label('Scan something')
