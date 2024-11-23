import math

# Constants
Q_FORMAT = 8  # Q8.8 format
MAX_VALUE = 2 ** 15 - 1  # Signed 16-bit maximum
MIN_VALUE = -2 ** 15  # Signed 16-bit minimum
LUT_SIZE = 512  # Quarter-wave LUT size
ANGLE_TO_RAD = (2 * math.pi) / 2048  # Conversion factor to radians

# Generate the sine LUT
sin_lut = []
for i in range(LUT_SIZE):
    angle_in_radians = i * ANGLE_TO_RAD
    sin_value = math.sin(angle_in_radians)
    q8_8_value = int(round(sin_value * (1 << Q_FORMAT)))

    # Clamp to 16-bit signed integer range
    if q8_8_value > MAX_VALUE:
        q8_8_value = MAX_VALUE
    elif q8_8_value < MIN_VALUE:
        q8_8_value = MIN_VALUE

    sin_lut.append(q8_8_value)

# Write to a file
with open("sin_lut.hex", "w") as f:
    for value in sin_lut:
        f.write(f"{value & 0xFFFF:04x}\n")
