import stl_map/frontend/leaflet/lat_lng.{type LatLng}
import stl_map/frontend/leaflet/map.{type Map}

pub type Circle

pub type Options {
  Options(color: String, radius: Int, fill_color: String, fill_opacity: Float)
}

@external(javascript, "../../../circle_ffi.mjs", "_new")
pub fn new(position: LatLng, options: Options) -> Circle

@external(javascript, "../../../circle_ffi.mjs", "add_to")
pub fn add_to(circle: Circle, map: Map) -> Circle

@external(javascript, "../../../circle_ffi.mjs", "remove")
pub fn remove(circle: Circle) -> Nil
