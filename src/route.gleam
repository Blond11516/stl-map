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

pub type Trip {
  Trip(id: String, headsign: String, shape: Shape, stops: List(Stop))
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

        Trip(
          trip_record.trip_id,
          trip_record.trip_headsign,
          Shape(trip_record.shape_id, shape_points),
          stops,
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
  json.array([route], of: fn(route) {
    json.object([
      #("name", json.string(route.name)),
      #("color", json.string(route.color)),
      #(
        "trips",
        json.array(route.trips, fn(trip) {
          json.object([
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
  })
  |> json.to_string()
}
