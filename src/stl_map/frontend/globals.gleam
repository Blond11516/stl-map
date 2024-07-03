import gleam/dict.{type Dict}
import plinth/browser/element.{type Element}
import stl_map/frontend/leaflet/map.{type Map}
import stl_map/frontend/leaflet/polyline.{type Polyline}

type PolylinesDict =
  Dict(String, Polyline)

pub fn init() -> Nil {
  set_polylines(dict.new())
}

@external(javascript, "../../globals_ffi.mjs", "get_start_time_preview")
pub fn get_start_time_preview() -> Element

@external(javascript, "../../globals_ffi.mjs", "set_start_time_preview")
pub fn set_start_time_preview(preview: Element) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_start_time")
pub fn get_start_time() -> Int

@external(javascript, "../../globals_ffi.mjs", "set_start_time")
pub fn set_start_time(value: Int) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_polylines")
pub fn get_polylines() -> PolylinesDict

@external(javascript, "../../globals_ffi.mjs", "set_polylines")
pub fn set_polylines(polylines: PolylinesDict) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_direction")
pub fn get_direction() -> Int

@external(javascript, "../../globals_ffi.mjs", "set_direction")
pub fn set_direction(direction: Int) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_map")
pub fn get_map() -> Map

@external(javascript, "../../globals_ffi.mjs", "set_map")
pub fn set_map(map: Map) -> Nil
