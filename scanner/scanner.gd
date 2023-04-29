extends Node3D

@onready var scanner_ui = $Viewport/ScannerUI
@onready var scan_area = $ScanArea
@onready var animation_player = $AnimationPlayer

func _on_scan_area_body_entered(body: Node3D):
    update_screen(body)

func _on_scan_area_body_exited(body: Node3D):
    update_screen(body)

func update_screen(body: Node3D):
    if scan_area.get_overlapping_bodies().size() == 1:
        scanner_ui.set_name_label(body.first_name + ' ' + body.last_name)
        scanner_ui.set_address_label(str(body.address))
        animation_player.play("scan_light")
    else:
        scanner_ui.set_name_label('Scan something')
        scanner_ui.set_address_label('Scan something')
