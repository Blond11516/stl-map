import common/direction
import common/route.{type Route, Route, Shape, ShapePoint, Stop, Trip}
import common/time_of_day.{type TimeOfDay}
import gleam/int
import gleam/list

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
  list.map(route_records, fn(route_record) {
    let trips =
      trip_records
      |> list.filter(fn(trip_record) {
        trip_record.route_id == route_record.route_id
      })
      |> list.map(fn(trip_record) {
        let shape_points =
          shape_records
          |> list.filter(fn(shape_record) {
            shape_record.shape_id == trip_record.shape_id
          })
          |> list.sort(by: fn(left, right) {
            int.compare(left.shape_pt_sequence, right.shape_pt_sequence)
          })
          |> list.map(fn(shape_record) {
            ShapePoint(shape_record.shape_pt_lat, shape_record.shape_pt_lon)
          })

        let stops =
          stop_time_records
          |> list.filter(fn(stop_time_record) {
            stop_time_record.trip_id == trip_record.trip_id
          })
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
