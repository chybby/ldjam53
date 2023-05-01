extends Control

const GUI = preload("res://menus/gui.gd")

@onready var dot_cursor := $Cursor/DotCursor
@onready var open_hand_cursor := $Cursor/OpenHandCursor
@onready var closed_hand_cursor := $Cursor/ClosedHandCursor
@onready var hover_controls := $HoverControls
@onready var grab_controls := $GrabControls
@onready var animation_player := $AnimationPlayer

func set_cursor(cursor: GUI.Cursor):
    dot_cursor.visible = false
    open_hand_cursor.visible = false
    closed_hand_cursor.visible = false
    hover_controls.visible = false
    grab_controls.visible = false
    match cursor:
        GUI.Cursor.DOT:
            dot_cursor.visible = true
        GUI.Cursor.OPEN_HAND:
            open_hand_cursor.visible = true
            hover_controls.visible = true
        GUI.Cursor.CLOSED_HAND:
            closed_hand_cursor.visible = true
            grab_controls.visible = true

func fade_out():
    animation_player.play("fade_out")
    return animation_player.animation_finished

func fade_in():
    animation_player.play_backwards("fade_out")
    return animation_player.animation_finished
