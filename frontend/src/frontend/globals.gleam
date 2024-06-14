import frontend/leaflet/map.{type Map}
import plinth/browser/element_type.{type Element}
import plinth/browser/object.{type Object}

@external(javascript, "../globals_ffi.mjs", "get_start_time_preview")
pub fn get_start_time_preview() -> Element

@external(javascript, "../globals_ffi.mjs", "set_start_time_preview")
pub fn set_start_time_preview(preview: Element) -> Nil

@external(javascript, "../globals_ffi.mjs", "get_start_time")
pub fn get_start_time() -> Int

@external(javascript, "../globals_ffi.mjs", "set_start_time")
pub fn set_start_time(value: Int) -> Nil

@external(javascript, "../globals_ffi.mjs", "get_polylines")
pub fn get_polylines() -> Object

@external(javascript, "../globals_ffi.mjs", "get_direction")
pub fn get_direction() -> Int

@external(javascript, "../globals_ffi.mjs", "set_direction")
pub fn set_direction(direction: Int) -> Nil

@external(javascript, "../globals_ffi.mjs", "set_map")
pub fn set_map(map: Map) -> Nil
