export function _new(container_id) {
  return L.map(container_id);
}

export function set_view(map, center, zoom) {
  return map.setView(center, zoom);
}
