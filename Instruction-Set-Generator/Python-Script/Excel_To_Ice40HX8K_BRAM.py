import xlrd, os.path
from string import Template

#--------------------------------Begin Settings---------------------------------

#Workbook path relative to the path of this file
current_dir = os.path.abspath(os.path.dirname(__file__))
workbook_path = os.path.join(current_dir, "../Instruction_Set_Microcode.xlsx")
#Verilog template file path
template_path = current_dir + "/BRAM_template_module.v"

#Output Verilog Module Name
output_module_name = "instruction_decoder"

#Workbook first row and column of data (Zero-Indexed)
workbook_first_row = 2
workbook_first_column = 2

#Determine how many rows of the excel sheet are used for each
address_bits = 8
data_bits = 16

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

def ingest(path): #Returns an array with all the 1s and 0s from the excel
    workbook = xlrd.open_workbook(workbook_path)
    current_sheet = workbook.sheet_by_index(0)

    array_data = []
    for i in range(workbook_first_row, current_sheet.nrows):
        array_data.append(current_sheet.row_values(i))
        for _ in range(workbook_first_column):
            array_data[-1].pop(0)
            
    array_data = [[0 if  i == 0.0 else 1 for i in array_row] for array_row in array_data]
    return array_data
    
def generate_bin_memory_array(ingested_data):
    #Create array for all memory address with all bits set to 0
    memory_array = [[0] * data_bits for _ in range(pow(2, address_bits))]

    for row in ingested_data:
        address = bin_array_to_int(row[0 : address_bits])
        data = row[address_bits : address_bits + data_bits]

        if address < (pow(2, address_bits)):
            for i in range(len(data)):
                if i < data_bits:
                    memory_array[address][i] = data[i]

    return memory_array

def generate_hex_strs_from_mem_array(memory_array):

    out_str = ""
    for row in memory_array:
        out_str = bin_array_to_hex_str(row) + out_str

    out_strs = [out_str[i : i + 64] for i in range(len(out_str) - 64, -1, -64)]

    return out_strs

def open_and_template_verilog(path, template_dic):
    filein = open(path)
    src = Template(filein.read())
    return src.safe_substitute(template_dic)

def main():
    ingested_data = ingest(workbook_path)
    mem_array = generate_bin_memory_array(ingested_data)
    hex_strs = generate_hex_strs_from_mem_array(mem_array)

    template_dic = {
        'module_name' : output_module_name,

        'data_0' : hex_strs[0],
        'data_1' : hex_strs[1],
        'data_2' : hex_strs[2],
        'data_3' : hex_strs[3],
        'data_4' : hex_strs[4],
        'data_5' : hex_strs[5],
        'data_6' : hex_strs[6],
        'data_7' : hex_strs[7],
        'data_8' : hex_strs[8],
        'data_9' : hex_strs[9],
        'data_A' : hex_strs[10],
        'data_B' : hex_strs[11],
        'data_C' : hex_strs[12],
        'data_D' : hex_strs[13],
        'data_E' : hex_strs[14],
        'data_F' : hex_strs[15],
    }

    print(open_and_template_verilog(template_path, template_dic))

main()