import { Polyline } from "./leaflet-src.esm.js";

export function _new(points, color) {
  return new Polyline(points, {
    color,
  });
}

export function add_to(line, map) {
  return line.addTo(map);
}

export function remove(line) {
  line.remove();
}
