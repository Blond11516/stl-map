import birl
import birl/duration
import gleam/int
import gleam/io
import gleam/list
import gtfs
import lustre/ssg
import route
import view

pub fn main() {
  let route_records = timed("load_routes", fn() { gtfs.load_routes() })
  let trip_records = timed("load_trips", fn() { gtfs.load_trips() })
  let shape_records = timed("load_shapes", fn() { gtfs.load_shapes() })
  let stop_time_records =
    timed("load_stop_times", fn() { gtfs.load_stop_times() })

  let routes =
    timed("assemble_routes", fn() {
      route.assemble_from_records(
        route_records,
        trip_records,
        shape_records,
        stop_time_records,
      )
    })

  timed("build app files", fn() {
    let ssg_config =
      ssg.new("./priv")
      |> ssg.add_static_route("/", view.view(routes))
      |> ssg.add_static_dir("assets")

    list.fold(routes, ssg_config, fn(ssg_config, route) {
      ssg.add_static_asset(
        ssg_config,
        "/" <> route.id <> ".json",
        route.to_json(route),
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
