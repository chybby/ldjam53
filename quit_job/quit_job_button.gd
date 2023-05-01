extends StaticBody3D

signal job_quitted

func hover(state):
    if state:
        print('hovered over job quitter')

func interact():
    job_quitted.emit()
