import { Map } from "./leaflet-src.esm";

export function _new(container_id) {
  return new Map(container_id);
}

export function set_view(map, center, zoom) {
  return map.setView(center, zoom);
}
