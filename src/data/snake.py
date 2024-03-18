import argparse
import numpy as np

def read_binary_file(file_name):
    # Assuming the binary data represents a series of integers
    with open(file_name, "rb") as file:
        data = np.fromfile(file, dtype=np.int32)
    return data

def snake_order(data, width):
    # Reshape the data into the desired matrix form
    rows = len(data) // width
    matrix = data[:rows*width].reshape((rows, width))
    
    # Apply "snake" order
    for i in range(1, rows, 2):
        matrix[i] = matrix[i][::-1]
    
    return matrix.flatten()

def save_binary_file(file_name, data):
    # Save the reordered data to a binary file
    with open(file_name, "wb") as file:
        data.tofile(file)

def main():
    parser = argparse.ArgumentParser(description="Reorder binary data in 'snake' format and save it to a file.")
    parser.add_argument("inputfile", type=str, help="Input file containing binary data.")
    parser.add_argument("-w", "--width", type=int, required=True, help="Width for the 'snake' format.")
    parser.add_argument("-o", "--outputfile", type=str, required=True, help="Output file to save the reordered data.")
    
    args = parser.parse_args()
    
    # Read the binary data
    data = read_binary_file(args.inputfile)
    
    # Reorder the data in "snake" format
    snake_data = snake_order(data, args.width)
    
    # Save the reordered data to the output file
    save_binary_file(args.outputfile, snake_data)

    print(f"Reordered data has been saved to {args.outputfile}")

if __name__ == "__main__":
    main()
