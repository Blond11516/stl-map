import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import stl_map/direction
import stl_map/gtfs/loader.{
  type RouteRecord, type ShapeRecord, type StopRecord, type StopTimeRecord,
  type TripRecord,
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
  let stop_records = loader.load_stops()
  io.println("Loaded stop records")

  io.println("Assembling routes")
  let routes =
    assemble_from_records(
      route_records,
      trip_records,
      shape_records,
      stop_time_records,
      stop_records,
    )
  io.println("Finished assembling routes")

  routes
}

fn assemble_from_records(
  route_records: List(RouteRecord),
  trip_records: List(TripRecord),
  shape_records: List(ShapeRecord),
  stop_time_records: List(StopTimeRecord),
  stop_records: List(StopRecord),
) -> List(Route) {
  let trip_records_by_route_id =
    list.group(trip_records, fn(trip_record) { trip_record.route_id })

  let shape_records_by_shape_id =
    list.group(shape_records, fn(shape_record) { shape_record.shape_id })

  let stop_time_records_by_trip_id =
    list.group(stop_time_records, fn(stop_time_record) {
      stop_time_record.trip_id
    })

  let stops_by_stop_id =
    stop_records
    |> list.map(fn(stop_record) { #(stop_record.stop_id, stop_record) })
    |> dict.from_list()

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
            ShapePoint(
              lat: shape_record.shape_pt_lat,
              lon: shape_record.shape_pt_lon,
            )
          })

        let assert Ok(current_trip_stop_time_records) =
          dict.get(stop_time_records_by_trip_id, trip_record.trip_id)

        let stops =
          current_trip_stop_time_records
          |> list.sort(by: fn(left, right) {
            int.compare(left.stop_sequence, right.stop_sequence)
          })
          |> list.map(fn(stop_time_record) {
            let assert Ok(stop) =
              dict.get(stops_by_stop_id, stop_time_record.stop_id)

            Stop(
              id: stop_time_record.stop_id,
              arrival_time: stop_time_record.arrival_time,
              departure_time: stop_time_record.departure_time,
              lat: stop.stop_lat,
              lon: stop.stop_lon,
            )
          })

        let assert Ok(Stop(arrival_time: start_time, ..)) = list.first(stops)

        let direction = direction.from_int(trip_record.direction_id)

        Trip(
          id: trip_record.trip_id,
          headsign: trip_record.trip_headsign,
          shape: Shape(id: trip_record.shape_id, points: shape_points),
          stops: stops,
          start_time: start_time,
          direction:,
        )
      })

    Route(
      id: route_record.route_id,
      name: route_record.route_short_name,
      trips:,
      color: route_record.route_color,
    )
  })
}
