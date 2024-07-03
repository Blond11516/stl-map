import birl
import birl/duration
import gleam/int
import gleam/io
import gleam/list
import lustre/ssg
import stl_map/route_json
import stl_map/routes_generator/gtfs
import stl_map/routes_generator/gtfs/loader as gtfs_loader
import stl_map/routes_generator/view

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

  timed("build app files", fn() {
    let ssg_config =
      ssg.new("./generated_assets/routes")
      |> ssg.add_static_route("/", view.view(routes))

    list.fold(routes, ssg_config, fn(ssg_config, route) {
      ssg.add_static_asset(
        ssg_config,
        "/" <> route.id <> ".json",
        route |> route_json.from_route() |> route_json.serialize(),
      )
    })
    |> ssg.build()
  })
}

fn timed(operation_name: String, operation: fn() -> a) -> a {
  io.println(operation_name <> ": Operation started")

  let before_time = birl.now()
  let operation_result = operation()
  let after_time = birl.now()

  let milliseconds =
    birl.difference(after_time, before_time)
    |> duration.blur_to(duration.MilliSecond)

  io.println(
    operation_name
    <> ": Operation completed in "
    <> int.to_string(milliseconds)
    <> "ms.",
  )

  operation_result
}
