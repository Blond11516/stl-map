import common/direction.{type Direction}
import common/route.{type Route}
import common/time_of_day.{type TimeOfDay}
import gleam/json
import gleam/list

pub type RouteJson {
  RouteJson(name: String, trips: List(TripJson), color: String)
}

pub type TripJson {
  TripJson(
    points: List(PointJson),
    stops: List(StopJson),
    start_time: TimeOfDay,
    direction: Direction,
  )
}

pub type StopJson {
  StopJson(id: String, arrival_time: TimeOfDay, departure_time: TimeOfDay)
}

pub type PointJson =
  List(Float)

pub fn from_route(route: Route) -> RouteJson {
  RouteJson(
    route.name,
    list.map(route.trips, fn(trip) {
      TripJson(
        list.map(trip.shape.points, fn(point) { [point.lat, point.lon] }),
        list.map(trip.stops, fn(stop) {
          StopJson(stop.id, stop.arrival_time, stop.departure_time)
        }),
        trip.start_time,
        trip.direction,
      )
    }),
    route.color,
  )
}

pub fn serialize(route: RouteJson) -> String {
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
            json.array(trip.points, of: fn(point) {
              json.array(point, of: json.float)
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
