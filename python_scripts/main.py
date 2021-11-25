import serial
import time
import pyautogui
from screeninfo import get_monitors

import mainCommands

autoInvertData: bool = False
screen_width: float
screen_height: float
stop_execution_flag: bool = False


def halt_execution():
    global stop_execution_flag
    stop_execution_flag = True


def setup_resolution():
    global screen_width, screen_height
    monitor = get_monitors()[0]
    screen_height = monitor.height
    screen_width = monitor.width
    mainCommands.setup_resolution(screen_width, screen_height)


def get_specific_bit_in_byte(byte, bit_number):
    return byte >> bit_number & 1


def translate_fpga_data_to_command(fpga_data):
    first_three_bits = fpga_data // 32
    print(mainCommands.commands[first_three_bits])
    mainCommands.commands[first_three_bits](fpga_data & 0b00011111)


def open_serial_port_to_fpga():
    return serial.Serial(
        port='/dev/ttyUSB0',
        baudrate=115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_TWO,
        bytesize=serial.EIGHTBITS
    )


def get_data_from_fpga(serial_port, wait_value=0.5):
    serial_port.write(0x41)
    time.sleep(wait_value)
    data = serial_port.read(serial_port.inWaiting())[0]
    if autoInvertData:
        data = ~data
    return data


fake_data = [
    0b00011111,
    0b00111111,
]


# data source for debugging
def get_fake_data(wait_value=0.5):
    global fake_data
    time.sleep(wait_value)
    if len(fake_data) == 0:
        return 0b11111111  # empty command
    new_data = fake_data[0]
    fake_data.pop(0)
    return new_data


def main():
    setup_resolution()
    serial_port = open_serial_port_to_fpga()
    try:
        while True:
            if stop_execution_flag:
                break
            # value = get_fake_data()
            value = get_data_from_fpga(serial_port)
            print([get_specific_bit_in_byte(value, i) for i in range(7, -1, -1)])
            translate_fpga_data_to_command(value)
    except Exception:
        print("cycle is closed!")
    finally:
        serial_port.close()


if __name__ == '__main__':
    main()

''' 
   Corners_test:
    0b10000001,
    0b10000010,
    0b10000011,
    0b10000100,
    0b10000101,
    0b10000110,
    0b10000111,
    0b10001000,
    0b10001001,
'''
