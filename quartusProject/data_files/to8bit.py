from PIL import Image

def srgb_to_8bit(r, g, b):
    """
    Convert 24-bit sRGB to 8-bit using:
    - 3 bits for red
    - 3 bits for green
    - 2 bits for blue
    """
    # Map each color channel to its reduced bit equivalent
    red = (r * 7) // 255  # 3 bits (0-7)
    green = (g * 7) // 255  # 3 bits (0-7)
    blue = (b * 3) // 255  # 2 bits (0-3)

    # Combine into a single 8-bit integer
    return (red << 5) | (green << 2) | blue

def process_image(image_path):
    """
    Load an image, resize to 64x64 if necessary, and convert to 8-bit sRGB.
    Store the resulting values in a 2D list.
    """
    # Open the image
    img = Image.open(image_path).convert("RGB")

    # Resize to 64x64 if not already
    img = img.resize((64, 64))

    # Initialize a 2D list to store 8-bit color values
    image_data = []

    # Process each pixel
    for y in range(64):
        row = []
        for x in range(64):
            r, g, b = img.getpixel((x, y))
            row.append(srgb_to_8bit(r, g, b))
        image_data.append(row)

    return image_data

# Example usage
if __name__ == "__main__":
    image_path = "smallFace.png"  # Replace with your image path
    result = process_image(image_path)
    big_result = ""
    for i in result:
        for j in i:
            big_result += format(j, '08b') + "\n"
    with open("paint2_texture.dat", 'w') as file:
        file.write(big_result)