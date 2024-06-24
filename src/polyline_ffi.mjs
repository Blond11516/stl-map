export function _new(points, color) {
  return L.polyline(points, {
    color,
  });
}

export function add_to(line, map) {
  line.addTo(map);
}

export function remove(line) {
  line.remove();
}
