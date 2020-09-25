from math import pi, sin


LSB_input = pi/(2**15 - 1)
LSB_rom = 1/(2**8 - 1)


def to_unsigned(number):
    MSB = len(number) - 1
    accumulator = 0

    for i, bit in enumerate(number):
        accumulator += int(bit)*(2**(MSB - i))

    return accumulator


def main():
    # ROM 1
    f = open("rom1.txt", 'w')
    f.write("constant rom : rom_t := (\n")

    for i in range(0, 1024):
        x_i = to_unsigned("{0:010b}".format(i) + "0000")*LSB_input
        x_i_plus_1 = to_unsigned("{0:010b}".format(i + 1) + "0000") * LSB_input
        ratio = (sin(x_i_plus_1) - sin(x_i)) / (x_i_plus_1 - x_i)
        data = "{0:08b}".format(round(ratio / LSB_rom))

        if i == 1023:
            f.write("\t\t\t\t\t\t " + '"' + str(data) + '"' + ");\n")
        else:
            f.write("\t\t\t\t\t\t " + '"' + str(data) + '"' + ",\n")

    f.close()

    # ROM 2
    f = open("rom2.txt", 'w')
    f.write("constant rom : rom_t := (\n")

    for i in range(0, 1024):
        x_i = to_unsigned("{0:010b}".format(i) + "0000")*LSB_input
        data = "{0:08b}".format(round(sin(x_i)/LSB_rom))

        if i == 1023:
            f.write("\t\t\t\t\t\t " + '"' + str(data) + '"' + ");\n")
        else:
            f.write("\t\t\t\t\t\t " + '"' + str(data) + '"' + ",\n")


if __name__ == "__main__":
    main()
