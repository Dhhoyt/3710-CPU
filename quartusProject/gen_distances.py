import math

def ray_cast_to_nearest_intersection(segments, position, angle):
    """
    Calculate the nearest intersection of a ray from a position at a given angle
    with a list of line segments.
    
    Parameters:
        segments (list of tuples): List of line segments (x1, y1, x2, y2).
        position (tuple): Player's position as (px, py).
        angle (float): Angle of the ray in degrees.
    
    Returns:
        tuple: Distance to nearest intersection along the ray and distance
               along the segment to the intersection point as (ray_distance, segment_distance).
               If no intersection, returns (float('inf'), float('inf')).
    """
    px, py = position
    ray_dx = math.cos(math.radians(angle))
    ray_dy = math.sin(math.radians(angle))

    nearest_distance = float(100)
    segment_distance = float(100)

    for x1, y1, x2, y2 in segments:
        # Segment direction vector
        segment_dx = x2 - x1
        segment_dy = y2 - y1

        # Denominator for the intersection equations
        denom = ray_dx * segment_dy - ray_dy * segment_dx
        
        if denom == 0:
            # Parallel or collinear
            continue
        
        # Compute intersection using parameterized line equations
        t_ray = ((x1 - px) * segment_dy - (y1 - py) * segment_dx) / denom
        t_segment = ((x1 - px) * ray_dy - (y1 - py) * ray_dx) / denom
        
        # Check if intersection is within bounds
        if t_ray >= 0 and 0 <= t_segment <= 1:
            ray_distance = t_ray
            if ray_distance < nearest_distance:
                nearest_distance = ray_distance
                segment_distance = t_segment * math.hypot(segment_dx, segment_dy)
    
    return nearest_distance, segment_distance - int(segment_distance)

walls = [(0, 2, 3, 2), (3, 2, 3, 4), (5, 0, 5, 5), (0, 5, 5, 5)]
player_pos = (4, 1)

fov = 103  # Field of view in degrees
heading = 90  # Player's heading in degrees

num_columns = 320

# Calculate the angle increment per column
angle_start = heading - fov / 2
angle_end = heading + fov / 2
angle_step = fov / num_columns
distances = ""
uvs = ""
# Cast rays for each column
for i in range(num_columns):
    angle = angle_start + i * angle_step
    distance, uv = ray_cast_to_nearest_intersection(walls, player_pos, angle)
    uv = int(uv * 64)
    print(f"Column {i}: Angle {angle:.2f}, Distance {distance}, uv {uv}")
    distances += "{:016b}".format(int(distance * 256)) + "\n"
    uvs += "{:06b}".format(uv) + "\n"
with open("distances.dat", 'w') as file:
    file.write(distances)
with open("uvs.dat", 'w') as file:
    file.write(uvs)