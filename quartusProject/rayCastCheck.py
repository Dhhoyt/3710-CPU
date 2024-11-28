import struct
import math

def parse_hex_line(line):
    """
    Parses a line of hex values. The first N-3 values are signed 16-bit integers,
    the third-to-last is a boolean, the second-to-last is an unsigned 16-bit integer,
    and the last is an unsigned 8-bit integer.
    """

    # Split the line by commas and strip any extra whitespace
    hex_values = [x.strip() for x in line.split(",")]

    # Convert the first 8 values to signed 16-bit integers
    signed_values = [int(x, 16) for x in hex_values[:8]]
    signed_values = [struct.unpack('>h', struct.pack('>H', val))[0] for val in signed_values]  # Convert to signed
    signed_values = [val/256 for val in signed_values]

    # Convert the third-to-last value to boolean
    intersection_flag = bool(int(hex_values[-3], 16))

    # Convert the second-to-last value to unsigned 16-bit integer
    distance = struct.unpack('>h', struct.pack('>H', int(hex_values[-2], 16)))[0]/256

    # Convert the last value to unsigned 8-bit integer
    uv = int(hex_values[-1], 16)
    # Return parsed values as a tuple
    return (*signed_values, intersection_flag, distance, uv, line)


def read_hex_file(filename):
    parsed_data = []
    with open(filename, 'r') as file:
        for line in file:
            parsed_line = parse_hex_line(line)
            if parsed_line is not None:
                parsed_data.append(parsed_line)
    return parsed_data

def is_ray_intersecting_segment(x1, y1, x2, y2, x3, y3, x4, y4, res, line):
    # Calculate the direction vectors of the ray and the line segment
    ray_dx, ray_dy = x1 - x2, y1 - y2
    wall_dx, wall_dy = x3 - x4, y3 - y4

    # Compute the denominator of the intersection formula (cross product of directions)
    denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    # If denom is zero, the lines are parallel or collinear
    if denom == 0:
        return (False, 0, 0, False)  # No intersection if parallel or collinear

    # Calculate the parameters t and u for the intersection point
    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
    u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom
    result = t >= 0 and 0 <= u <= 1
    if not result and res:
        print("bruh", t, u)
    dist = math.sqrt((ray_dx * ray_dx) + (ray_dy * ray_dy)) * t
    # The intersection occurs within the ray (t >= 0) and within the segment (0 <= u <= 1)
    return (result, t, u, dist)

# Example usage
filename = 'output.txt'
data = read_hex_file(filename)
count = 0
correct = 0
incorrect = 0
total_diff = 0
max_diff = 0
max_data = ("", 0, 0)
for entry in data:
    result = is_ray_intersecting_segment(entry[0], entry[1], entry[2], entry[3], entry[4], entry[5], entry[6], entry[7], entry[8], entry[9])
    if result[0] == entry[8]:
        correct += 1
        if result[0]:
            diff = abs(entry[9] - result[3])
            total_diff += diff
            count += 1
            if max_diff < diff:
                max_diff = diff
                
                max_data = (entry, entry[9], result[3])
            pass
    else:
        print(result[1], result[2], entry[8], result[0])
        incorrect += 1
    if not result[0] and entry[8]:
        print("bruh" + entry[11])
print(correct, incorrect)
print(max_data, max_diff)
print(total_diff/count)