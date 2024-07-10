import gleam/list
import gleam/option.{type Option, None}
import gleam/string
import simplifile
import stl_map/gtfs
import stl_map/route.{type Route}
import stl_map/route_json

pub fn main() -> Nil {
  build(None)
}

pub fn build(routes: Option(List(Route))) -> Nil {
  let _ = simplifile.create_directory("./dist")
  let _ = simplifile.create_directory("./dist/routes")

  let routes = option.lazy_unwrap(routes, gtfs.load_routes)

  list.each(routes, fn(route) {
    route
    |> route_json.from_route()
    |> route_json.serialize()
    |> simplifile.write(
      to: "./dist/routes/" <> string.uppercase(route.id) <> ".json",
    )
  })
}
