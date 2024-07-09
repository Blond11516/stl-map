import { Polyline } from "./leaflet-src.esm";

export function _new(points, color) {
  return new Polyline(points, {
    color,
  });
}

export function add_to(line, map) {
  line.addTo(map);
}

export function remove(line) {
  line.remove();
}
