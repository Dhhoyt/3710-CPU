import math

def hex_to_q8_8(hex_str):
    """Convert unsigned hex Q8.8 fixed-point string to decimal."""
    # Convert hex to integer
    num = int(hex_str, 16)
    # Convert to Q8.8 by dividing by 256
    return num / 256.0

def hex_to_q16_16(hex_str):
    """Convert unsigned hex Q8.8 fixed-point string to decimal."""
    # Convert hex to integer
    num = int(hex_str, 16)
    # Convert to Q8.8 by dividing by 256
    return num / (2**16)

def process_file(filename):
    with open(filename, 'r') as file:
        total_difference = 0
        max_difference = 0
        max_difference_input = 0
        max_difference_output = 0
        for line in file:
            # Strip any whitespace and split the line by tab
            hex1, hex2 = line.strip().split('\t')

            # Convert hex values to Q8.8 fixed-point decimals
            print()
            num1 = hex_to_q16_16(hex1)
            num2 = hex_to_q8_8(hex2)

            # Calculate square root of the first number and the difference
            sqrt_num1 = math.sqrt(num1)
            difference = sqrt_num1 - num2

            # Print the result
            total_difference += difference
            print(f"sqrt({num1:.6f}) = {num2:.6f}\t\tError: {difference:.6f}")
            if difference > max_difference:
                max_difference = difference
                max_difference_input = num1
                max_difference_output = num2
        print("Sqrt Circuit Test Results:")
        average_difference = total_difference/ (2 ** 16)
        print(f"Average error of {average_difference:.6f}")
        print(f"Max error at sqrt({max_difference_input:.6f}) = {max_difference_output:.6f}\tError: {max_difference:.6f}")

# Run the function with the filename
process_file("output.txt")
