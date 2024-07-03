import stl_map/frontend/leaflet/lat_lng.{type LatLng}

pub type Map

@external(javascript, "../../../map_ffi.mjs", "_new")
pub fn new(container_id: String) -> Map

@external(javascript, "../../../map_ffi.mjs", "set_view")
pub fn set_view(map: Map, center: LatLng, zoom: Float) -> Map
