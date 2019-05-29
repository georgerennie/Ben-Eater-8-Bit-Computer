import xlrd, os.path

#--------------------------------Begin Settings---------------------------------

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

print(ingest_instructions(workbook_path))