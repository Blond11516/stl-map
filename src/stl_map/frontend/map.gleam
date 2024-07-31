import gleam/dict
import gleam/javascript/array
import gleam/list
import stl_map/frontend/globals
import stl_map/frontend/leaflet/circle.{type Circle}
import stl_map/frontend/leaflet/lat_lng.{type LatLng}
import stl_map/frontend/leaflet/map.{type Map}
import stl_map/frontend/leaflet/polyline.{type Polyline}
import stl_map/route_json.{type TripJson}

pub fn draw_route(trip: TripJson, route_color: String, route_id: String) -> Nil {
  let points = list.map(trip.points, point_json_to_lat_lng)

  let map = globals.get_map()

  let route_polyline = draw_line(points, route_color, map)

  let stop_circles =
    trip.stops
    |> list.drop(1)
    |> list.map(fn(stop) {
      stop.point
      |> point_json_to_lat_lng()
      |> draw_stop(route_color, map, False)
    })

  let assert Ok(line_start) = list.first(points)
  let start_circle = draw_stop(line_start, route_color, map, True)

  globals.get_selected_routes()
  |> dict.insert(
    route_id,
    globals.SelectedRoute(route_polyline, start_circle, stop_circles),
  )
  |> globals.set_selected_routes()
}

fn point_json_to_lat_lng(point: route_json.PointJson) -> LatLng {
  let assert [lat, lon] = point
  lat_lng.new(lat, lon)
}

fn draw_line(points: List(LatLng), route_color: String, map: Map) -> Polyline {
  points
  |> array.from_list()
  |> polyline.new(route_color)
  |> polyline.add_to(map)
}

fn draw_stop(
  position: LatLng,
  route_color: String,
  map: Map,
  first: Bool,
) -> Circle {
  let fill_color = case first {
    True -> "white"
    False -> route_color
  }

  position
  |> circle.new(circle.Options(
    color: route_color,
    radius: 100,
    fill_color: fill_color,
    fill_opacity: 1.0,
  ))
  |> circle.add_to(map)
}

pub fn remove_route(route_id: String) -> Nil {
  let assert Ok(selected_route) =
    globals.get_selected_routes()
    |> dict.get(route_id)

  polyline.remove(selected_route.polyline)

  circle.remove(selected_route.start_circle)

  list.each(selected_route.stop_circles, circle.remove)

  globals.get_selected_routes()
  |> dict.delete(route_id)
  |> globals.set_selected_routes()

  Nil
}
