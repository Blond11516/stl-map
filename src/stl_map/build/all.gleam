import gleam/option.{Some}
import stl_map/build/index
import stl_map/build/js
import stl_map/build/routes
import stl_map/routes_generator/gtfs
import stl_map/routes_generator/gtfs/loader as gtfs_loader
import stl_map/timed.{timed}

pub fn main() {
  let route_records = timed("load_routes", fn() { gtfs_loader.load_routes() })
  let trip_records = timed("load_trips", fn() { gtfs_loader.load_trips() })
  let shape_records = timed("load_shapes", fn() { gtfs_loader.load_shapes() })
  let stop_time_records =
    timed("load_stop_times", fn() { gtfs_loader.load_stop_times() })

  let routes =
    timed("assemble_routes", fn() {
      gtfs.assemble_from_records(
        route_records,
        trip_records,
        shape_records,
        stop_time_records,
      )
    })

  index.build(Some(routes))
  routes.build(Some(routes))
  js.build()
}
