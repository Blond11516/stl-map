import globals from "./globals.mjs";
import { from_list } from "../gleam_javascript/gleam/javascript/array.mjs";

export function add_to_map(line_id, line) {
  const polyline = L.polyline([from_list(line.points)], {
    color: line.color,
  });
  polyline.addTo(globals.map);
  globals.polylines[line_id] = polyline;
}

export function remove(line) {
  line.remove();
}
