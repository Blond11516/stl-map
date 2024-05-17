import gleam/int
import gleam/json
import gleam/list
import gtfs.{
  type RouteRecord, type ShapeRecord, type StopTimeRecord, type TripRecord,
}
import time_of_day.{type TimeOfDay}

pub type Route {
  Route(id: String, name: String, trips: List(Trip), color: String)
}

pub type Direction {
  Zero
  One
}

pub type Trip {
  Trip(
    id: String,
    headsign: String,
    shape: Shape,
    stops: List(Stop),
    start_time: TimeOfDay,
    direction: Direction,
  )
}

pub type Shape {
  Shape(id: String, points: List(ShapePoint))
}

pub type ShapePoint {
  ShapePoint(lat: Float, lon: Float)
}

pub type Stop {
  Stop(id: String, arrival_time: TimeOfDay, departure_time: TimeOfDay)
}

pub fn assemble_from_records(
  route_records: List(RouteRecord),
  trip_records: List(TripRecord),
  shape_records: List(ShapeRecord),
  stop_time_records: List(StopTimeRecord),
) {
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

        let direction = direction_from_int(trip_record.direction_id)

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

pub fn to_json(route: Route) {
  json.object([
    #("name", json.string(route.name)),
    #("color", json.string(route.color)),
    #(
      "trips",
      json.array(route.trips, fn(trip) {
        json.object([
          #("start_time", json.string(time_of_day.present(trip.start_time))),
          #("direction", json.int(direction_to_int(trip.direction))),
          #(
            "points",
            json.array(trip.shape.points, of: fn(point) {
              json.array([point.lat, point.lon], of: json.float)
            }),
          ),
          #(
            "stops",
            json.array(trip.stops, of: fn(stop) {
              json.object([
                #("id", json.string(stop.id)),
                #(
                  "arrival_time",
                  json.string(time_of_day.present(stop.arrival_time)),
                ),
                #(
                  "departure_time",
                  json.string(time_of_day.present(stop.departure_time)),
                ),
              ])
            }),
          ),
        ])
      }),
    ),
  ])
  |> json.to_string()
}

fn direction_from_int(direction_id: Int) -> Direction {
  case direction_id {
    0 -> Zero
    1 -> One
    _ -> panic as "Direction IDs should always be 0 or 1"
  }
}

fn direction_to_int(direction: Direction) -> Int {
  case direction {
    Zero -> 0
    One -> 1
  }
}
