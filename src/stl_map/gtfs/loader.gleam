import gleam/float
import gleam/int
import gleam/list
import gleam/string
import simplifile
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

pub type StopRecord {
  StopRecord(stop_id: String, stop_lat: Float, stop_lon: Float)
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
    ShapeRecord(
      shape_id: shape_id,
      shape_pt_lat: lat,
      shape_pt_lon: lon,
      shape_pt_sequence: sequence,
    )
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
      direction_id,
      _block_id,
      shape_id,
      _wheelchair_accessible,
    ] = string.split(trip, ",")
    let assert Ok(direction) = int.parse(direction_id)
    TripRecord(
      trip_id:,
      route_id:,
      trip_headsign:,
      shape_id:,
      direction_id: direction,
    )
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
      route_color,
      _route_text_color,
    ] = string.split(route, ",")
    RouteRecord(route_id:, route_short_name:, route_color: "#" <> route_color)
  })
}

pub fn load_stop_times() -> List(StopTimeRecord) {
  read_file("stop_times.txt")
  |> list.drop(1)
  |> list.map(fn(stop_time) {
    let assert [
      trip_id,
      arrival_time,
      departure_time,
      stop_id,
      stop_sequence,
      _stop_headsign,
      _pickup_type,
      _drop_off_type,
      _shape_dist_traveled,
      _timepoint,
    ] = string.split(stop_time, ",")
    let assert Ok(parsed_stop_sequence) = int.parse(stop_sequence)
    StopTimeRecord(
      trip_id:,
      arrival_time: time_of_day.parse_time_of_day(arrival_time),
      departure_time: time_of_day.parse_time_of_day(departure_time),
      stop_id:,
      stop_sequence: parsed_stop_sequence,
    )
  })
}

pub fn load_stops() -> List(StopRecord) {
  read_file("stops.txt")
  |> list.drop(1)
  |> list.map(fn(stop) {
    let assert [
      stop_id,
      _stop_code,
      _stop_name,
      _stop_desc,
      stop_lat,
      stop_lon,
      _zone_id,
      _stop_url,
      _location_type,
      _parent_station,
      _wheelchair_boarding,
    ] = string.split(stop, ",")
    let assert Ok(lat) = float.parse(stop_lat)
    let assert Ok(lon) = float.parse(stop_lon)
    StopRecord(stop_id:, stop_lat: lat, stop_lon: lon)
  })
}

fn read_file(filename: String) -> List(String) {
  let assert Ok(content) = simplifile.read(from: "./gtfs_stlevis/" <> filename)

  content
  |> string.trim()
  |> string.split("\r\n")
}
