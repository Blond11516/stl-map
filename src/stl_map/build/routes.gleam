import gleam/list
import gleam/option.{type Option, None}
import gleam/string
import simplifile
import stl_map/route.{type Route}
import stl_map/route_json
import stl_map/routes_generator/gtfs
import stl_map/routes_generator/gtfs/loader as gtfs_loader
import stl_map/timed.{timed}

pub fn main() -> Nil {
  build(None)
}

pub fn build(routes: Option(List(Route))) -> Nil {
  let _ = simplifile.create_directory("./dist")

  let routes =
    option.lazy_unwrap(routes, fn() {
      let route_records =
        timed("load_routes", fn() { gtfs_loader.load_routes() })
      let trip_records = timed("load_trips", fn() { gtfs_loader.load_trips() })
      let shape_records =
        timed("load_shapes", fn() { gtfs_loader.load_shapes() })
      let stop_time_records =
        timed("load_stop_times", fn() { gtfs_loader.load_stop_times() })

      timed("assemble_routes", fn() {
        gtfs.assemble_from_records(
          route_records,
          trip_records,
          shape_records,
          stop_time_records,
        )
      })
    })

  timed("build app files", fn() {
    let _ = simplifile.create_directory("./dist/routes")

    list.each(routes, fn(route) {
      route
      |> route_json.from_route()
      |> route_json.serialize()
      |> simplifile.write(
        to: "./dist/routes/" <> string.uppercase(route.id) <> ".json",
      )
    })
  })
}
