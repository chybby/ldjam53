extends Control

const GUI = preload("res://menus/gui.gd")

@onready var dot_cursor := $Cursor/DotCursor
@onready var open_hand_cursor := $Cursor/OpenHandCursor
@onready var closed_hand_cursor := $Cursor/ClosedHandCursor

func set_cursor(cursor: GUI.Cursor):
    dot_cursor.visible = false
    open_hand_cursor.visible = false
    closed_hand_cursor.visible = false
    match cursor:
        GUI.Cursor.DOT:
            dot_cursor.visible = true
        GUI.Cursor.OPEN_HAND:
            open_hand_cursor.visible = true
        GUI.Cursor.CLOSED_HAND:
            closed_hand_cursor.visible = true
