extends Control

signal next_dialog

const GUI = preload("res://menus/gui.gd")

@onready var dot_cursor := $Cursor/DotCursor
@onready var open_hand_cursor := $Cursor/OpenHandCursor
@onready var closed_hand_cursor := $Cursor/ClosedHandCursor
@onready var hover_controls := $HoverControls
@onready var hover_controls_label := $HoverControls/Label
@onready var grab_controls := $GrabControls
@onready var grab_controls_label := $GrabControls/Label
@onready var animation_player := $AnimationPlayer
@onready var dialog_box := $Dialog
@onready var dialog_label := $Dialog/VBoxContainer/DialogLabel
@onready var dialog_animation_player := $DialogAnimationPlayer

func set_cursor(cursor: GUI.Cursor, instructions: String):
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
            hover_controls_label.text = instructions
            hover_controls.visible = true
        GUI.Cursor.CLOSED_HAND:
            closed_hand_cursor.visible = true
            grab_controls_label.text = instructions
            grab_controls.visible = true

func fade_out():
    animation_player.play("fade_out")
    return animation_player.animation_finished

func fade_in():
    animation_player.play_backwards("fade_out")
    return animation_player.animation_finished

func _gui_input(event):
    if event.is_action_pressed('next_dialog'):
        if dialog_animation_player.is_playing():
            dialog_animation_player.advance(999)
        else:
            dialog_box.visible = false
            next_dialog.emit()

func show_dialog(text: String):
    dialog_box.visible = true
    dialog_label.text = text
    dialog_animation_player.play("scroll_dialog", -1, 20.0/text.length())
