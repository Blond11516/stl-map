import gleam/float
import gleam/int
import gleam/list
import gleam/string
import simplifile

pub type RouteRecord {
  RouteRecord(route_id: String, route_short_name: String)
}

pub type TripRecord {
  TripRecord(
    trip_id: String,
    route_id: String,
    trip_headsign: String,
    shape_id: String,
  )
}

pub type ShapeRecord {
  Shape(
    shape_id: String,
    shape_pt_lat: Float,
    shape_pt_lon: Float,
    shape_pt_sequence: Int,
  )
}

pub fn load_shapes() -> List(ShapeRecord) {
  read_file("shapes.txt")
  |> list.drop(1)
  |> list.map(fn(shape) {
    let assert [
      shape_id,
      shape_pt_lat,
      shape_pt_lon,
      shape_pt_sequence,
      _shape_dist_traveled,
    ] = string.split(shape, ",")
    let assert Ok(lat) = float.parse(shape_pt_lat)
    let assert Ok(lon) = float.parse(shape_pt_lon)
    let assert Ok(sequence) = int.parse(shape_pt_sequence)
    Shape(shape_id, lat, lon, sequence)
  })
}

pub fn load_trips() -> List(TripRecord) {
  read_file("trips.txt")
  |> list.drop(1)
  |> list.map(fn(trip) {
    let assert [
      route_id,
      _service_id,
      trip_id,
      trip_headsign,
      _trip_short_name,
      _direction_id,
      _block_id,
      shape_id,
      _wheelchair_accessible,
    ] = string.split(trip, ",")
    TripRecord(trip_id, route_id, trip_headsign, shape_id)
  })
}

pub fn load_routes() -> List(RouteRecord) {
  read_file("routes.txt")
  |> list.drop(1)
  |> list.map(fn(route) {
    let assert [
      route_id,
      _agency_id,
      route_short_name,
      _route_long_name,
      _route_desc,
      _route_type,
      _route_url,
      _route_color,
      _route_text_color,
    ] = string.split(route, ",")
    RouteRecord(route_id, route_short_name)
  })
}

fn read_file(filename: String) -> List(String) {
  let assert Ok(routes) = simplifile.read(from: "./gtfs_stlevis/" <> filename)
  routes
  |> string.trim()
  |> string.split("\r\n")
}
