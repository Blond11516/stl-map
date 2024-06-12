import globals from "./globals.mjs";

export function add_to_map(line_id, line) {
  const polyline = L.polyline([line.points], {
    color: line.color,
  });
  polyline.addTo(globals.map);
  globals.polylines[line_id] = polyline;
}

export function remove(line) {
  line.remove();
}
