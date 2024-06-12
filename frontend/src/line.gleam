import common/route.{type ShapePoint}

pub type Line {
  Line(points: List(ShapePoint), color: String)
}

@external(javascript, "./line_ffi.mjs", "add_to_map")
pub fn add_to_map(line_id: String, line: Line) -> Nil

@external(javascript, "./line_ffi.mjs", "remove")
pub fn remove(line: Line) -> Nil
