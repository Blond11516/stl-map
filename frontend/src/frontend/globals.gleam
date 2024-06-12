import plinth/browser/element_type.{type Element}
import plinth/browser/object.{type Object}

@external(javascript, "../globals_ffi.mjs", "get_start_time_preview")
pub fn get_start_time_preview() -> Element

@external(javascript, "../globals_ffi.mjs", "set_start_time")
pub fn set_start_time(value: Int) -> Nil

@external(javascript, "../globals_ffi.mjs", "get_polylines")
pub fn get_polylines() -> Object
