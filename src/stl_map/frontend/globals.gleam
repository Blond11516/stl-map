import gleam/dict.{type Dict}
import plinth/browser/element.{type Element}
import stl_map/frontend/leaflet/circle.{type Circle}
import stl_map/frontend/leaflet/map.{type Map}
import stl_map/frontend/leaflet/polyline.{type Polyline}

pub type SelectedRoute {
  SelectedRoute(
    polyline: Polyline,
    start_circle: Circle,
    stop_circles: List(Circle),
  )
}

type SelectedRoutesDict =
  Dict(String, SelectedRoute)

pub fn init() -> Nil {
  set_selected_routes(dict.new())
}

@external(javascript, "../../globals_ffi.mjs", "get_start_time_preview")
pub fn get_start_time_preview() -> Element

@external(javascript, "../../globals_ffi.mjs", "set_start_time_preview")
pub fn set_start_time_preview(preview: Element) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_start_time")
pub fn get_start_time() -> Int

@external(javascript, "../../globals_ffi.mjs", "set_start_time")
pub fn set_start_time(value: Int) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_selected_routes")
pub fn get_selected_routes() -> SelectedRoutesDict

@external(javascript, "../../globals_ffi.mjs", "set_selected_routes")
pub fn set_selected_routes(selected_routes: SelectedRoutesDict) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_direction")
pub fn get_direction() -> Int

@external(javascript, "../../globals_ffi.mjs", "set_direction")
pub fn set_direction(direction: Int) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get_map")
pub fn get_map() -> Map

@external(javascript, "../../globals_ffi.mjs", "set_map")
pub fn set_map(map: Map) -> Nil
