import gleam/option.{Some}
import stl_map/build/index
import stl_map/build/js
import stl_map/build/routes
import stl_map/gtfs

pub fn main() {
  let routes = gtfs.load_routes()

  index.build(Some(routes))
  routes.build(Some(routes))
  js.build()
}
