import pyautogui

import main

screen_width: float
screen_height: float


def setup_resolution(width, height):
    global screen_width, screen_height
    screen_height = height
    screen_width = width


def stop_execution():
    main.halt_execution()
    return


def generate_mouse_position_function(x01, y01):
    def func():
        pyautogui.moveTo(x01 * screen_width, y01 * screen_height)

    return func


def backspace():
    pyautogui.press('backspace')


def left_click():
    pyautogui.leftClick()


def right_click():
    pyautogui.rightClick()


def middle_click():
    pyautogui.middleClick()


def scroll_up():
    pyautogui.vscroll(10)


def scroll_down():
    pyautogui.vscroll(-10)


commands = [
    stop_execution,  # 0
    generate_mouse_position_function(0.5, 0.5),  # 1 (mid)
    generate_mouse_position_function(0.5, 0.001),  # 2 (n)
    generate_mouse_position_function(0.5, 0.999),  # 3 (s)
    generate_mouse_position_function(1, 0.5),  # 4 (e)
    generate_mouse_position_function(0.001, 0.5),  # 5 (w)
    generate_mouse_position_function(1, 0.999),  # 6 (se)
    generate_mouse_position_function(1, 0.111),  # 7 (ne)
    generate_mouse_position_function(0.001, 0.995),  # 8 (sw)
    generate_mouse_position_function(0.001, 0),  # 9 (nw)
    left_click,  # 10
    right_click,  # 11
    middle_click,  # 12
    scroll_up,  # 13
    scroll_down,  # 14!
    backspace  # 15
]
