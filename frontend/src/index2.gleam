import common/route.{ShapePoint}
import common/time_of_day
import frontend
import frontend/globals
import frontend/leaflet/lat_lng
import frontend/leaflet/map
import frontend/leaflet/tile_layer
import gleam/int
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/option.{Some}
import gleam/order.{Lt}
import gleam/result
import line.{Line}
import plinth/browser/document
import plinth/browser/element
import plinth/browser/element_type.{type Element}
import plinth/browser/event.{type Event}
import plinth/browser/object

const form_id = "routes-form"

pub fn list_route_checkboxes() -> Array(Element) {
  document.query_selector_all("#" <> form_id <> " input[type=checkbox]")
}

pub fn change_start_time(e: Event) -> Nil {
  let assert Ok(start_time) = int.parse(e.target.value)

  element.set_text_content(
    globals.get_start_time_preview(),
    frontend.format_start_time(start_time),
  )
  globals.set_start_time(start_time)

  list_route_checkboxes()
  |> array.to_list()
  |> list.each(fn(checkbox) {
    case checkbox.checked {
      True -> {
        let route_name = checkbox.name
        remove_line(route_name)
        add_line(route_name)
        Nil
      }
      False -> Nil
    }
  })
}

pub fn add_line(route_id: String) -> Promise(Nil) {
  let route_data_promise = frontend.get_route_data(route_id)
  use route <- promise.map(route_data_promise)

  let start_time = frontend.time_from_minutes(globals.get_start_time())

  let trip =
    route.trips
    |> list.sort(fn(a, b) { time_of_day.compare(a.start_time, b.start_time) })
    |> list.find(fn(trip) {
      case globals.get_direction() == trip.direction {
        False -> False
        True -> {
          time_of_day.compare(start_time, trip.start_time) == Lt
        }
      }
    })

  case trip {
    Ok(trip) -> {
      let points =
        list.map(trip.points, fn(point_json) {
          let assert [lat, lon] = point_json
          ShapePoint(lat, lon)
        })
      line.add_to_map(route_id, Line(points, route.color))
    }
    Error(_) -> Nil
  }
}

pub fn remove_line(route_id: String) -> Nil {
  let polylines = globals.get_polylines()
  case object.in(polylines, route_id) {
    True -> {
      let assert Some(polyline) =
        globals.get_polylines()
        |> object.get(route_id)

      line.remove(polyline)

      globals.get_polylines()
      |> object.delete(route_id)

      Nil
    }
    False -> Nil
  }
}

pub fn change_selected_routes(e: Event) -> Nil {
  case e.target.checked {
    True -> {
      add_line(e.target.name)
      Nil
    }
    False -> remove_line(e.target.name)
  }
}

pub fn change_direction(e: Event) -> Nil {
  let assert Ok(direction) = int.parse(e.target.value)
  globals.set_direction(direction)

  list_route_checkboxes()
  |> array.to_list()
  |> list.each(fn(checkbox) {
    case checkbox.checked {
      True -> {
        let route_name = checkbox.name
        remove_line(route_name)
        add_line(route_name)
        Nil
      }
      False -> Nil
    }
  })
}

pub fn change_routes(e: Event) -> Nil {
  case e.target.name {
    "startAfter" -> change_start_time(e)
    "direction" -> change_direction(e)
    _ -> change_selected_routes(e)
  }
}

const levis_lat = 46.736269

const levis_lon = -71.2535253

const initial_zoom = 11.65

pub fn init() -> Nil {
  let map =
    map.new("map")
    |> map.set_view(lat_lng.new(levis_lat, levis_lon), initial_zoom)

  globals.set_map(map)

  // TODO implement OSM usage policies: https://operations.osmfoundation.org/policies/tiles/
  tile_layer.new(
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    tile_layer.Options(
      19.0,
      "&copy; <a href=\"http://www.openstreetmap.org/copyright\">OpenStreetMap</a>",
    ),
  )
  |> tile_layer.add_to(map)

  let _ =
    document.get_element_by_id(form_id)
    |> result.map(fn(form) {
      element.add_event_listener(form, "change", change_routes)
    })

  let _ =
    document.query_selector("input[name=direction]:checked")
    |> result.try(fn(input) { int.parse(input.value) })
    |> result.map(globals.set_direction)

  list_route_checkboxes()
  |> array.to_list()
  |> list.filter(fn(checkbox) { checkbox.checked })
  |> list.each(fn(checkbox) { add_line(checkbox.name) })

  let assert Ok(start_time_preview) =
    document.get_element_by_id("startTimePreview")

  globals.set_start_time_preview(start_time_preview)

  let assert Ok(start_time) =
    document.query_selector("input[name=startAfter]")
    |> result.try(fn(input) { int.parse(input.value) })

  globals.set_start_time(start_time)

  element.set_text_content(
    start_time_preview,
    frontend.format_start_time(start_time),
  )

  Nil
}
