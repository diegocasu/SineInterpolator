from math import sin, pi
import json

LOG_ENABLED = False


def print(*args, **kwargs):
    if LOG_ENABLED:
        return __builtins__.print(*args, **kwargs)


def check_num_bits(number, num_bits):
    if len(number) != num_bits:
        print("ERROR: the number of bits is different from the target one. ")
        print("ACTUAL NUMBER OF BITS: " + str(len(number)))
        print("REQUIRED NUMBER OF BITS: " + str(num_bits))
        exit()


def to_real(sign, number, LSB):
    MSB = len(number) - 1
    accumulator = 0

    for i, bit in enumerate(number):
        accumulator += int(bit)*(2**(MSB - i))

    accumulator *= (-1)**(int(sign))
    return accumulator*LSB


def to_unsigned(number):
    MSB = len(number) - 1
    accumulator = 0

    for i, bit in enumerate(number):
        accumulator += int(bit)*(2**(MSB - i))

    return accumulator


def start(net_input, LSB_input):
    print("--------------------")
    print("START STAGE")
    print("--------------------")
    check_num_bits(net_input, num_bits=16)

    input_value = to_real(net_input[0], net_input[1:], LSB_input)
    print("NETWORK INPUT: " + net_input)
    print("REAL VALUE: " + str(input_value))
    print("SINE: " + str(sin(input_value)))
    print("--------------------\n")


def complement(number, LSB_input, enable):
    print("--------------------")
    print("COMPLEMENT STAGE")
    print("--------------------")
    check_num_bits(number, num_bits=14)
    check_num_bits(enable, num_bits=1)

    result = number
    if enable == '1':
        result = ''.join([str(1 - int(bit)) for bit in number])

    print("ENABLE: " + enable)
    print("INPUT: " + number)
    print("COMPLEMENT: " + result)
    print("REAL VALUE: " + str(to_real('0', result, LSB_input)))
    print("SINE: " + str(sin(to_real('0', result, LSB_input))))
    print("--------------------\n")

    return result


def rom_1(address, LSB_input, LSB_rom):
    print("--------------------")
    print("ROM 1 STAGE")
    print("--------------------")
    check_num_bits(address, num_bits=10)

    # ROM initialization
    data = []
    for i in range(0, 1024):
        x_i = to_unsigned("{0:010b}".format(i) + "0000") * LSB_input
        x_i_plus_1 = to_unsigned("{0:010b}".format(i+1) + "0000") * LSB_input
        ratio = (sin(x_i_plus_1) - sin(x_i))/(x_i_plus_1 - x_i)
        data.append("{0:08b}".format(round(ratio/LSB_rom)))

    # Return the requested value
    int_address = to_unsigned(address)

    print("ADDRESS: " + address + " (" + str(int_address) + ")")
    print("DATA: " + data[int_address])
    print("REAL VALUE: " + str(to_unsigned(data[int_address])*LSB_rom))
    print("--------------------\n")

    return data[int_address]


def rom_2(address, LSB_input, LSB_rom):
    print("--------------------")
    print("ROM 2 STAGE")
    print("--------------------")
    check_num_bits(address, num_bits=10)

    # ROM initialization
    data = []
    for i in range(0, 1024):
        x_i = to_unsigned("{0:010b}".format(i) + "0000")*LSB_input
        data.append("{0:08b}".format(round(sin(x_i)/LSB_rom)))

    # Return the requested value
    int_address = to_unsigned(address)

    print("ADDRESS: " + address + " (" + str(int_address) + ")")
    print("DATA: " + data[int_address])
    print("REAL VALUE: " + str(to_unsigned(data[int_address])*LSB_rom))
    print("--------------------\n")

    return data[int_address]


def multiplier(rom1_data, x_minus_x_i):
    print("--------------------")
    print("MULTIPLIER STAGE")
    print("--------------------")
    check_num_bits(rom1_data, num_bits=8)
    check_num_bits(x_minus_x_i, num_bits=4)

    result = "{0:012b}".format(to_unsigned(rom1_data)*to_unsigned(x_minus_x_i))

    print("INPUT 1: " + rom1_data)
    print("INPUT 2: " + x_minus_x_i)
    print("OUTPUT: " + result)
    print("--------------------\n")

    return result


def LSB_converter(out_mul, LSB_ratio):
    print("--------------------")
    print("LSB CONVERTER STAGE")
    print("--------------------")
    check_num_bits(out_mul, num_bits=8)

    converted = "{0:022b}".format(round(to_unsigned(out_mul)*LSB_ratio))

    LSB_input = pi/(2**15 - 1)
    LSB_rom = 1/(2**8 - 1)

    print("INPUT: " + out_mul)
    print("OUTPUT: " + converted)
    print("PREVIOUS REAL VALUE: " + str(to_unsigned(out_mul)*LSB_rom))
    print("REAL VALUE: " + str(to_unsigned(converted)*LSB_input*LSB_rom))


    return converted


def adder(rom2_data, out_mul):
    check_num_bits(rom2_data, num_bits=22)
    check_num_bits(out_mul, num_bits=22)

    return "{0:023b}".format(to_unsigned(out_mul) + to_unsigned(rom2_data))


def end(sign, result, LSB_rom):
    print("--------------------")
    print("END STAGE")
    print("--------------------")
    check_num_bits(result, num_bits=23)

    print("SINE: " + sign + result)
    print("SINE REAL VALUE: " + str(to_real(sign, result, LSB_rom)))
    print("--------------------\n")


def circuit(net_input, LSB_input, LSB_rom):
    # Visual information about the inputs
    start(net_input, LSB_input)

    # D Flip Flop that saves the sign bit
    sign = net_input[0]

    # Complement network
    compl = complement(net_input[2:], LSB_input, enable=net_input[1])

    # ROMs
    x_i = compl[0:10]
    rom1_data = rom_1(x_i, LSB_input, LSB_rom)
    rom2_data = rom_2(x_i, LSB_input, LSB_rom)

    # Multiplier: inputs on 8 and 4 bits, output on 12 bits with LSB = LSB_input*LSB_rom
    out_mul = multiplier(rom1_data, x_minus_x_i=compl[10:])

    # Converter: output with LSB = LSB_input*LSB_rom
    # The output is converted from LSB_start = LSB_rom to LSB_end = LSB_input*LSB_rom
    # multiplying the real value by the ratio LSB_ratio = LSB_start/LSB_end
    # and then rounding the result (it must be an integer).
    # 1/LSB_input is approximately 10430 (same number used in VHDL).
    out_conv = LSB_converter(rom2_data, LSB_ratio=10430)

    # Adder: inputs on 22 bits, output on 23 bits with LSB = LSB_input*LSB_rom
    out_mul_extended = "0000000000" + out_mul
    out_adder = adder(out_conv, out_mul_extended)

    # Final result
    end(sign, out_adder, LSB_input*LSB_rom)

    # Return sine as a string of bits.
    return sign + out_adder


def print_results_to_file(LSB_input, LSB_rom):
    file_results = open("results.txt", 'w')

    file_results_rom = open("results_rom.txt", 'w')
    file_results_rom.write("constant rom : rom_t := (\n")

    for i in range(0, 2**16):
        print("ITERATION: " + str(i))

        net_input = "{0:016b}".format(i)
        interpolated_sine = circuit(net_input, LSB_input, LSB_rom)

        data = {"INPUT": to_real(net_input[0], net_input[1:], LSB_input), "INPUT_BIT": net_input,
                "OUTPUT": to_real(net_input[0], interpolated_sine[1:], LSB_input*LSB_rom), "OUTPUT_BIT": interpolated_sine}

        # Write to file.
        file_results.write(json.dumps(data) + '\n')

        if i == 2**16 - 1:
            file_results_rom.write("\t\t\t\t\t\t " + '"' + interpolated_sine + '"' + ");\n")
        else:
            file_results_rom.write("\t\t\t\t\t\t " + '"' + interpolated_sine + '"' + ",\n")

    file_results.close()
    file_results_rom.close()


def main():
    global LOG_ENABLED
    LOG_ENABLED = True

    # LSBs for the input and the data stored in the ROMs.
    LSB_input = pi/(2**15 - 1)
    LSB_rom = 1/(2**8 - 1)

    # SINGLE TEST (16-bit input, signed fixed point)
    net_input = "1101001101001111"
    interpolated_sine = circuit(net_input, LSB_input, LSB_rom)

    # MULTIPLE TESTS (all the possible input values). Saves the results to file.
    print_results_to_file(LSB_input, LSB_rom)


if __name__ == "__main__":
    main()
