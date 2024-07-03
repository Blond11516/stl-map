import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import stl_map/direction
import stl_map/route.{type Route, Route, Shape, ShapePoint, Stop, Trip}
import stl_map/time_of_day.{type TimeOfDay}

pub type RouteRecord {
  RouteRecord(route_id: String, route_short_name: String, route_color: String)
}

pub type TripRecord {
  TripRecord(
    trip_id: String,
    route_id: String,
    trip_headsign: String,
    shape_id: String,
    direction_id: Int,
  )
}

pub type ShapeRecord {
  ShapeRecord(
    shape_id: String,
    shape_pt_lat: Float,
    shape_pt_lon: Float,
    shape_pt_sequence: Int,
  )
}

pub type StopTimeRecord {
  StopTimeRecord(
    trip_id: String,
    arrival_time: TimeOfDay,
    departure_time: TimeOfDay,
    stop_id: String,
    stop_sequence: Int,
  )
}

pub fn assemble_from_records(
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
