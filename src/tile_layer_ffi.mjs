import { TileLayer } from "./leaflet-src.esm.js";

export function _new(url, options) {
  return new TileLayer(url, options);
}

export function add_to(tile_layer, map) {
  tile_layer.addTo(map);
}
