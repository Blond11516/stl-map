import frontend/leaflet/lat_lng.{type LatLng}
import frontend/leaflet/map.{type Map}
import gleam/javascript/array.{type Array}

pub type Polyline

@external(javascript, "../../polyline_ffi.mjs", "_new")
pub fn new(points: Array(LatLng), color: String) -> Polyline

@external(javascript, "../../polyline_ffi.mjs", "add_to")
pub fn add_to(line: Polyline, map: Map) -> Polyline

@external(javascript, "../../polyline_ffi.mjs", "remove")
pub fn remove(line: Polyline) -> Nil
