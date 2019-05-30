import xlrd, os.path, sys

#--------------------------------Begin Settings---------------------------------
#NOTE: The source path needs to be passed as the first cmd line argument after
#this file name

#Workbook path relative to the path of this file
current_dir = os.path.abspath(os.path.dirname(__file__))
workbook_path = os.path.join(current_dir, "../../../Instruction-Set-Generator/Instruction_Set_Microcode.xlsx")

#Workbook first row of data
workbook_first_row = 2
#Workbook instruction name column
instr_col = 0
#Workbook first instruction bit column
first_bit_col = 2
#Number of bits per instruction in workbook
instr_bits = 4

#Number of memory addresses
mem_addresses = 16

#---------------------------------End Settings----------------------------------

def bin_array_to_int(binary):
    int_out = 0
    for i in range(len(binary)):
        int_out += (binary[-i-1] != 0) * (1 << (i))
    return int_out

def bin_array_nibble_to_hex_char(binary):
    out_char = ""
    int_of_bin = bin_array_to_int(binary)
    if (int_of_bin <= 9): out_char = str(int_of_bin)
    else: out_char = chr(int_of_bin+55)
    return out_char
    
def bin_array_to_hex_str(binary):
    out_str = ""

    while (len(binary) % 4) != 0:
        binary = [0] + binary

    for i in range(0, int(len(binary) / 4)):
        out_str += bin_array_nibble_to_hex_char(binary[4 * i : 4 * i + 4])

    return out_str

def ingest_instructions(path):
    workbook = xlrd.open_workbook(path)
    current_sheet = workbook.sheet_by_index(0)

    instr_dic = {}

    for i in range(workbook_first_row, current_sheet.nrows):
        instr_name = current_sheet.cell_value(i, instr_col)
        if  instr_name != "":
            row = current_sheet.row_values(i)
            instr_bin = row[first_bit_col : first_bit_col + instr_bits]
            instr_hex = bin_array_to_hex_str(instr_bin)
            instr_dic[instr_name] = instr_hex

    return instr_dic

def read_src_path():
    arguments = sys.argv
    if len(arguments) != 2:
        except_str = "Wrong number of cmd line arguments. Found "
        except_str += str(len(arguments))
        raise Exception(except_str)
    return arguments[1]

def read_src_to_lines(path):
    file = open(path)
    text = file.read()
    file.close()
    return text.splitlines()

def add_line_numbers_to_src(src):
    for i, line in enumerate(src):
        src[i] = [i + 1, line]
    return src

def remove_comments(src):
    for i, line in enumerate(src):
        split_by_comment = line[1].split("#")
        src[i][1] = split_by_comment[0]
    return src

def split_by_spaces(src):
    for i, line in enumerate(src):
        split_by_space = line[1].split(" ")
        src[i][1] = split_by_space
    return src

def remove_empty_addresses(src):
    src = [x for x in src if x] #If the line isnt empty keep text
    return src

def remove_empty_addresses_2d(src):
    for i, line in enumerate(src):
        src[i][1] = remove_empty_addresses(line[1])
    src = [x for x in src if x[1]]
    return src

def raise_illegal_lines(src):
    for line in src:
        if (not line[1][0].isdigit() or
            int(line[1][0]) >= mem_addresses):

            except_str = "Line " + str(line[0]) + ": "
            except_str += "Memory address is invalid"
            raise Exception(except_str)

        if (len(line[1]) < 2 or len(line[1]) > 3):
        
            except_str = "Line " + str(line[0]) + ": "
            except_str += "Invalid number of arguments supplied"
            raise Exception(except_str)

def pre_process_src(src):
    src = add_line_numbers_to_src(src)
    src = remove_comments(src)
    src = split_by_spaces(src)
    src = remove_empty_addresses_2d(src)
    raise_illegal_lines(src)
    return src

def interpret_value_to_hex(value):
    out_hex = ""
    designator = value[0].lower()
    if (designator == "h"):
        out_hex = value[1 : ].upper()
    
    elif (designator == "b"):
        bin_arr = [ int(x) for x in value[1 : ]]
        out_hex = bin_array_to_hex_str(bin_arr)
    
    elif (designator == "d"):
        out_hex = str(hex(int(value[1 : ]))).upper()
    
    return out_hex

def generate_memory_map(src, instr_dic):
    mem_map = [["0"] * 2 for _ in range(mem_addresses)]
    for line in src:
        addr = int(line[1][0])
        data = ["0", "0"]

        instr = line[1][1].upper()

        if (instr == "VAL"):
            val = interpret_value_to_hex(line[1][2])
            data[0] = val[0]
            data[1] = val[1]
        
        elif (instr in instr_dic):
            data[0] = instr_dic[instr]
            if (len(line[1]) >= 3):
                val = interpret_value_to_hex(line[1][2])
                #TODO: raise error if wrong length of val
                data[1] = val[-1]

        else:
            except_str = "Line " + str(line[0]) + ": "
            except_str += "Instruction unrecognised"
            raise Exception(except_str)

        mem_map[addr] = data

    return mem_map

def mem_map_to_BRAM_hex(mem_map):
    out_str = ""
    for line in mem_map:
        out_str = line[0] + line[1] + out_str
    
    #Pad to 64 chars
    out_str = ("0" * (64 - len(out_str))) + out_str
    return out_str
        
def main():
    src_path = read_src_path()
    src = read_src_to_lines(src_path)
    src = pre_process_src(src)

    instr_dic = ingest_instructions(workbook_path)
    mem_map = generate_memory_map(src, instr_dic)

    BRAM_hex = mem_map_to_BRAM_hex(mem_map)
    print(BRAM_hex)

main()