import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import stl_map/direction
import stl_map/gtfs/loader.{
  type RouteRecord, type ShapeRecord, type StopTimeRecord, type TripRecord,
}
import stl_map/route.{type Route, Route, Shape, ShapePoint, Stop, Trip}

pub fn load_routes() -> List(Route) {
  let route_records = loader.load_routes()
  io.println("Loaded route records")
  let trip_records = loader.load_trips()
  io.println("Loaded trip records")
  let shape_records = loader.load_shapes()
  io.println("Loaded shape records")
  let stop_time_records = loader.load_stop_times()
  io.println("Loaded stop time records")

  io.println("Assembling routes")
  let routes =
    assemble_from_records(
      route_records,
      trip_records,
      shape_records,
      stop_time_records,
    )
  io.println("Finished assembling routes")

  routes
}

fn assemble_from_records(
  route_records: List(RouteRecord),
  trip_records: List(TripRecord),
  shape_records: List(ShapeRecord),
  stop_time_records: List(StopTimeRecord),
) -> List(Route) {
  let trip_records_by_route_id =
    list.group(trip_records, fn(trip_record) { trip_record.route_id })

  let shape_records_by_shape_id =
    list.group(shape_records, fn(shape_record) { shape_record.shape_id })

  let stop_time_records_by_trip_id =
    list.group(stop_time_records, fn(stop_time_record) {
      stop_time_record.trip_id
    })

  list.map(route_records, fn(route_record) {
    io.println("Processing route " <> route_record.route_id)

    let assert Ok(current_route_trip_records) =
      dict.get(trip_records_by_route_id, route_record.route_id)

    let trips =
      current_route_trip_records
      |> list.map(fn(trip_record) {
        let assert Ok(current_trip_shape_records) =
          dict.get(shape_records_by_shape_id, trip_record.shape_id)

        let shape_points =
          current_trip_shape_records
          |> list.sort(by: fn(left, right) {
            int.compare(left.shape_pt_sequence, right.shape_pt_sequence)
          })
          |> list.map(fn(shape_record) {
            ShapePoint(shape_record.shape_pt_lat, shape_record.shape_pt_lon)
          })

        let assert Ok(current_trip_stop_time_records) =
          dict.get(stop_time_records_by_trip_id, trip_record.trip_id)

        let stops =
          current_trip_stop_time_records
          |> list.sort(by: fn(left, right) {
            int.compare(left.stop_sequence, right.stop_sequence)
          })
          |> list.map(fn(stop_time_record) {
            Stop(
              stop_time_record.stop_id,
              stop_time_record.arrival_time,
              stop_time_record.departure_time,
            )
          })

        let assert Ok(Stop(_, start_time, _)) = list.first(stops)

        let direction = direction.from_int(trip_record.direction_id)

        Trip(
          trip_record.trip_id,
          trip_record.trip_headsign,
          Shape(trip_record.shape_id, shape_points),
          stops,
          start_time,
          direction,
        )
      })

    Route(
      route_record.route_id,
      route_record.route_short_name,
      trips,
      route_record.route_color,
    )
  })
}
