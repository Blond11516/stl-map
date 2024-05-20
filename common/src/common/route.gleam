import common/direction.{type Direction}
import common/time_of_day.{type TimeOfDay}
import gleam/json

pub type Route {
  Route(id: String, name: String, trips: List(Trip), color: String)
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

pub fn to_json(route: Route) {
  json.object([
    #("name", json.string(route.name)),
    #("color", json.string(route.color)),
    #(
      "trips",
      json.array(route.trips, fn(trip) {
        json.object([
          #("start_time", json.string(time_of_day.present(trip.start_time))),
          #("direction", json.int(direction.to_int(trip.direction))),
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
