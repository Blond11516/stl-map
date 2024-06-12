export function _new(url, options) {
  return L.tileLayer(url, options);
}

export function add_to(tile_layer, map) {
  tile_layer.addTo(map);
}
