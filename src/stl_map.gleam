import gleam/list
import gtfs
import lustre/ssg
import route
import view

pub fn main() {
  let route_records = gtfs.load_routes()
  let trip_records = gtfs.load_trips()
  let shape_records = gtfs.load_shapes()
  let stop_time_records = gtfs.load_stop_times()

  let routes =
    route.assemble_from_records(
      route_records,
      trip_records,
      shape_records,
      stop_time_records,
    )

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
}
