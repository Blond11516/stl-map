import stl_map/frontend/leaflet/map.{type Map}

pub type TileLayer

pub type Options {
  Options(max_zoom: Float, attribution: String)
}

@external(javascript, "../../../tile_layer_ffi.mjs", "_new")
pub fn new(url: String, options: Options) -> TileLayer

@external(javascript, "../../../tile_layer_ffi.mjs", "add_to")
pub fn add_to(tile_layer: TileLayer, map: Map) -> Nil
