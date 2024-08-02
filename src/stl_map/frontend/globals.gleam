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

const start_time_preview_key = "start_time_preview"

pub fn get_start_time_preview() -> Element {
  get(start_time_preview_key)
}

pub fn set_start_time_preview(preview: Element) -> Nil {
  set(start_time_preview_key, preview)
}

const start_time_key = "start_time"

pub fn get_start_time() -> Int {
  get(start_time_key)
}

pub fn set_start_time(value: Int) -> Nil {
  set(start_time_key, value)
}

const selected_routes_key = "selected_routes"

pub fn get_selected_routes() -> SelectedRoutesDict {
  get(selected_routes_key)
}

pub fn set_selected_routes(selected_routes: SelectedRoutesDict) -> Nil {
  set(selected_routes_key, selected_routes)
}

const direction_key = "direction"

pub fn get_direction() -> Int {
  get(direction_key)
}

pub fn set_direction(direction: Int) -> Nil {
  set(direction_key, direction)
}

const map_key = "map"

pub fn get_map() -> Map {
  get(map_key)
}

pub fn set_map(map: Map) -> Nil {
  set(map_key, map)
}

@external(javascript, "../../globals_ffi.mjs", "set")
fn set(key: String, value: a) -> Nil

@external(javascript, "../../globals_ffi.mjs", "get")
fn get(key: String) -> a
