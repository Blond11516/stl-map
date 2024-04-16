import gtfs.{type RouteRecord, type ShapeRecord, type TripRecord}
import gleam/list
import gleam/int
import gleam/json

pub type Route {
  Route(id: String, name: String, trips: List(Trip))
}

pub type Trip {
  Trip(id: String, headsign: String, shape: Shape)
}

pub type Shape {
  Shape(id: String, points: List(ShapePoint))
}

pub type ShapePoint {
  ShapePoint(lat: Float, lon: Float)
}

pub fn assemble_from_records(
  route_records: List(RouteRecord),
  trip_records: List(TripRecord),
  shape_records: List(ShapeRecord),
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

        Trip(
          trip_record.trip_id,
          trip_record.trip_headsign,
          Shape(trip_record.shape_id, shape_points),
        )
      })

    Route(route_record.route_id, route_record.route_short_name, trips)
  })
}

pub fn present(routes: List(Route)) {
  routes
  |> list.take(1)
  |> list.map(fn(route) {
    let assert [trip, ..] = route.trips

    #(route.name, trip.shape.points)
  })
  |> json.array(of: fn(route_info) {
    let #(name, points) = route_info
    json.object([
      #("name", json.string(name)),
      #(
        "points",
        json.array(points, of: fn(point) {
          json.array([point.lat, point.lon], of: json.float)
        }),
      ),
    ])
  })
  |> json.to_string()
}
