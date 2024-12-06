from svg.path import parse_path
from xml.dom import minidom


def get_point_at(path, distance, scale, offset):
    pos = path.point(distance)
    pos += offset
    pos *= scale
    return pos.real, pos.imag


def points_from_path(path, density, scale, offset):
    step = int(path.length() * density)
    last_step = step - 1

    if last_step == 0:
        yield get_point_at(path, 0, scale, offset)
        return

    for distance in range(step):
        yield get_point_at(
            path, distance / last_step, scale, offset)


def lines_from_doc(doc, density=5, scale=1, offset=0):
    offset = offset[0] + offset[1] * 1j
    lines = []
    for element in doc.getElementsByTagName("path"):
        for segment in parse_path(element.getAttribute("d")):
            lines.append([segment.point(0), segment.point(1)]) 
            # points.extend(points_from_path(
            #     path, density, scale, offset))
    return lines


doc = minidom.parse('labyrinth.svg')
points = lines_from_doc(doc, density=1, scale=1, offset=(0, 0))
doc.unlink()

print(points)
