import xlrd
import os.path

#Workbook path relative to the path of this file
current_path = os.path.abspath(os.path.dirname(__file__))
workbook_path = os.path.join(current_path, "../Instruction_Set_Microcode.xlsx")

#Workbook first row and column of data (Zero-Indexed)
workbook_first_row = 2
workbook_first_column = 2

#Determine how many rows of the excel sheet are used for each
address_bits = 8
data_bits = 8

def ingest(path): #Returns an array with all the 1s and 0s from the excel
    workbook = xlrd.open_workbook(workbook_path)
    current_sheet = workbook.sheet_by_index(0)

    array_data = []
    for i in range(workbook_first_row, current_sheet.nrows):
        array_data.append(current_sheet.row_values(i))
        for j in range(workbook_first_column):
            array_data[-1].pop(0)
            
    array_data = [[0 if  i == 0.0 else 1 for i in array_row] for array_row in array_data]
    return array_data

def bin_array_to_int(binary):
    int_out = 0
    for i in range(len(binary)):
        int_out += (binary[-i-1] != 0) * (1 << (i))
    return int_out   

ingest(workbook_path)