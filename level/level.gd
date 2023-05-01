extends Node3D

@onready var package_spawn_point := $PackageSpawnPoint
@onready var player_tutorial_spawn_point := $PlayerTutorialSpawnPoint
@onready var player_spawn_point := $PlayerSpawnPoint
@onready var customer_spawn_point := $CustomerSpawnPoint
@onready var car_spawn_point1 := $CarSpawnPoint1
@onready var car_spawn_point2 := $CarSpawnPoint2
@onready var customer_exit_area := $CustomerExitArea
@onready var animation_player := $AnimationPlayer
@onready var alarm_sound := $AlarmSound

func get_player_tutorial_spawn_position():
    return player_tutorial_spawn_point.global_position

func get_player_tutorial_spawn_rotation():
        return player_tutorial_spawn_point.global_rotation

func get_player_spawn_position():
    return player_spawn_point.global_position

func get_package_spawn_position():
    return package_spawn_point.global_position

func get_customer_spawn_position():
    return customer_spawn_point.global_position

func get_car_spawn1_position():
    return car_spawn_point1.global_position

func get_car_spawn1_rotation():
    return car_spawn_point1.global_rotation

func get_car_spawn2_position():
    return car_spawn_point2.global_position


func get_customer_exit_position():
    return customer_exit_area.global_position

func turn_on_light():
    animation_player.play("spinning_light")
    alarm_sound.play()

func turn_off_light():
    animation_player.play("RESET")
    alarm_sound.stop()
