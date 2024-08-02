import gleam/json
import gleam/list
import stl_map/direction
import stl_map/route.{type Route}
import stl_map/time_of_day.{type TimeOfDay}

pub type RouteJson {
  RouteJson(name: String, trips: List(TripJson), color: String)
}

pub type TripJson {
  TripJson(
    points: List(PointJson),
    stops: List(StopJson),
    start_time: TimeOfDay,
    direction: Int,
  )
}

pub type StopJson {
  StopJson(
    id: String,
    arrival_time: TimeOfDay,
    departure_time: TimeOfDay,
    point: PointJson,
  )
}

pub type PointJson =
  List(Float)

pub fn from_route(route: Route) -> RouteJson {
  RouteJson(
    name: route.name,
    trips: list.map(route.trips, fn(trip) {
      TripJson(
        points: list.map(trip.shape.points, fn(point) { [point.lat, point.lon] }),
        stops: list.map(trip.stops, fn(stop) {
          StopJson(
            id: stop.id,
            arrival_time: stop.arrival_time,
            departure_time: stop.departure_time,
            point: [stop.lat, stop.lon],
          )
        }),
        start_time: trip.start_time,
        direction: direction.to_int(trip.direction),
      )
    }),
    color: route.color,
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
          #("direction", json.int(trip.direction)),
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
                #("point", json.array(stop.point, of: json.float)),
              ])
            }),
          ),
        ])
      }),
    ),
  ])
  |> json.to_string()
}
