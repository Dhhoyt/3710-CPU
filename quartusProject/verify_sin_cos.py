import math

def hex_to_q8_8(hex_value):
    """Convert a signed Q8.8 hex value to a floating-point number."""
    # Convert the hex value to an integer
    int_value = int(hex_value, 16)
    # If the value is negative in Q8.8 format (two's complement), adjust accordingly
    if int_value & 0x8000:  # Check if sign bit is set
        int_value -= 0x10000 # Convert to negative range
    return int_value / 256.0  # Convert to floating point number

def process_file(file_path):
    # Initialize variables to track the total and maximum differences
    total_diff = 0.0
    max_diff = 0.0
    num_lines = 0
    
    # Open the file and read it line by line
    with open(file_path, 'r') as file:
        for line in file:
            # Strip whitespace and ignore empty lines
            line = line.strip()
            if not line:
                continue

            # Split the line into the three hex values for x, sin(x), and cos(x)
            parts = line.split()
            if len(parts) != 3:
                print(f"Skipping invalid line: {line}")
                continue
            
            # Parse the Q8.8 values from the hex strings
            x_hex, sin_x_hex, cos_x_hex = parts
            x = hex_to_q8_8(x_hex)
            sin_x_obs = hex_to_q8_8(sin_x_hex)
            cos_x_obs = hex_to_q8_8(cos_x_hex)
            
            # Calculate the expected values of sin(x) and cos(x)
            sin_x_exp = math.sin((x * 2 * math.pi) / 8)
            cos_x_exp = math.cos((x * 2 * math.pi) / 8)
            print(x_hex, sin_x_hex)
            print(f"x: {x} cos exp: {cos_x_exp} \t sin obs: {cos_x_obs}")
            # Calculate the absolute differences
            sin_diff = abs(sin_x_exp - sin_x_obs)
            cos_diff = abs(cos_x_exp - cos_x_obs)
            
            # Update the total and max differences
            total_diff += sin_diff + cos_diff
            max_diff = max(max_diff, sin_diff, cos_diff)
            num_lines += 1

    # Calculate the average difference
    avg_diff = total_diff / (num_lines * 2) if num_lines > 0 else 0

    return avg_diff, max_diff

# Main execution
if __name__ == "__main__":
    # Specify the file path
    file_path = 'data.txt'  # Replace with your file path

    avg_diff, max_diff = process_file(file_path)

    print(f"Average Difference: {avg_diff:.6f}")
    print(f"Maximum Difference: {max_diff:.6f}")