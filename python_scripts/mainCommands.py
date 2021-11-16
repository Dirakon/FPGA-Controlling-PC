import main
import pyautogui
import advancedCommands

screen_width: float
screen_height: float


def setup_resolution(width, height):
    global screen_width, screen_height
    screen_height = height
    screen_width = width
    advancedCommands.setup_resolution(width, height)


def move_mouse_general(x_shift_signed, y_shift_signed):
    half_width = 0.5 * screen_width
    half_height = 0.5 * screen_height
    x_shift_signed = (x_shift_signed / 32) * half_width
    y_shift_signed = (y_shift_signed / 32) * half_height
    pyautogui.moveRel(x_shift_signed, y_shift_signed)


def move_mouse_right(value):
    move_mouse_general(value, 0)


def move_mouse_left(value):
    move_mouse_general(-value, 0)


def move_mouse_up(value):
    move_mouse_general(0, -value)


def move_mouse_down(value):
    move_mouse_general(0, value)


def activate_advanced_command(value):
    # make use of other 5 bits (32 options)
    if value < len(advancedCommands.commands):
        print(advancedCommands.commands[value])
        advancedCommands.commands[value]()


def input_english_letter(value):
    # 26 letters + 6 special symbols = 32 options     hello world!!!!!!!!!!!!!
    alphabet = [chr(ord('a') + i) for i in range(26)]
    alphabet.insert(0,' ')
    for specialSymbol in ['.', ',', '!', '?', ':']:
        alphabet.append(specialSymbol)
    pyautogui.press(alphabet[value])


def input_number(value):
    # number from 0 to 31 (last 5 bits)
    pyautogui.typewrite(str(value))


def empty_command(value):
    # just wait
    return


commands = [move_mouse_right,  # 0
            move_mouse_left,  # 1
            move_mouse_up,  # 2
            move_mouse_down,  # 3
            activate_advanced_command,  # 4
            input_english_letter,  # 5
            input_number,  # 6
            empty_command]  # 7
