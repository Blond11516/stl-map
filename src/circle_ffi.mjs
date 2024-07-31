import { Circle } from "./leaflet-src.esm.js";

export function _new(position, options) {
  return new Circle(position, {
    ...options,
    fillColor: options.fill_color,
    fillOpacity: options.fill_opacity,
  });
}

export function add_to(circle, map) {
  return circle.addTo(map);
}

export function remove(circle) {
  circle.remove();
}
