import numpy as np

def snake_order_bytes(data, width):
    height = len(data) // width
    snake_data = bytearray(len(data))
    
    for row in range(height):
        for col in range(width):
            if row % 2 == 0:
                snake_data[row*width + col] = data[row*width + col]
            else:
                snake_data[row*width + (width - 1 - col)] = data[row*width + col]
    return snake_data

def process_file(input_filename, output_filename, snake_width):
    try:
        with open(input_filename, 'rb') as file:
            data = file.read()
        
        snake_data = snake_order_bytes(data, snake_width)
        
        with open(output_filename, 'wb') as file:
            file.write(snake_data)
            
        print("Process completed successfully.")
    except IOError as e:
        print(f"An error occurred: {e}")

# Example usage
input_filename = "ZXNEXT_64x64.raw"
output_filename = "ZXNEXT_64x64_snake.raw"
snake_width = 64

# Run the process
process_file(input_filename, output_filename, snake_width)
