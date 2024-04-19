import gtfs
import lustre/ssg
import route
import view

pub fn main() {
  let route_records = gtfs.load_routes()
  let trip_records = gtfs.load_trips()
  let shape_records = gtfs.load_shapes()

  let routes =
    route.assemble_from_records(route_records, trip_records, shape_records)

  ssg.new("./priv")
  |> ssg.add_static_route("/", view.view(routes))
  |> ssg.add_static_dir("assets")
  |> ssg.add_static_asset("/routes.json", route.present(routes))
  |> ssg.build()
}
