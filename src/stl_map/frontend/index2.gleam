import gleam/dict
import gleam/dynamic
import gleam/int
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/order.{Lt}
import gleam/result
import plinth/browser/document
import plinth/browser/element.{type Element}
import plinth/browser/event.{type Event}
import stl_map/frontend/frontend
import stl_map/frontend/globals
import stl_map/frontend/leaflet/lat_lng
import stl_map/frontend/leaflet/map as leaflet_map
import stl_map/frontend/leaflet/tile_layer
import stl_map/frontend/map
import stl_map/time_of_day

const form_id = "routes-form"

pub fn list_route_checkboxes() -> Array(Element) {
  document.query_selector_all("#" <> form_id <> " input[type=checkbox]")
}

pub fn change_start_time(e: Event) -> Nil {
  let assert Ok(start_time) =
    e
    |> event.target()
    |> dynamic.unsafe_coerce()
    |> element.value()
    |> result.then(int.parse)

  element.set_text_content(
    globals.get_start_time_preview(),
    frontend.format_start_time(start_time),
  )
  globals.set_start_time(start_time)

  list_route_checkboxes()
  |> array.to_list()
  |> list.each(fn(checkbox) {
    let checked = element.get_checked(checkbox)
    case checked {
      True -> {
        let assert Ok(route_name) = element.get_attribute(checkbox, "name")
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
      map.draw_route(trip, route.color, route_id)
    }
    Error(_) -> Nil
  }
}

pub fn remove_line(route_id: String) -> Nil {
  let selected_routes = globals.get_selected_routes()
  case dict.has_key(selected_routes, route_id) {
    True -> map.remove_route(route_id)
    False -> Nil
  }
}

pub fn change_selected_routes(e: Event) -> Nil {
  let checkbox = e |> event.target() |> dynamic.unsafe_coerce()
  let checked = element.get_checked(checkbox)
  let assert Ok(name) = element.get_attribute(checkbox, "name")
  case checked {
    True -> {
      add_line(name)
      Nil
    }
    False -> remove_line(name)
  }
}

pub fn change_direction(e: Event) -> Nil {
  let assert Ok(direction) =
    e
    |> event.target()
    |> dynamic.unsafe_coerce()
    |> element.get_attribute("value")
    |> result.then(int.parse)
  globals.set_direction(direction)

  list_route_checkboxes()
  |> array.to_list()
  |> list.each(fn(checkbox) {
    let checked = element.get_checked(checkbox)
    let assert Ok(name) = element.get_attribute(checkbox, "name")
    case checked {
      True -> {
        let route_name = name
        remove_line(route_name)
        add_line(route_name)
        Nil
      }
      False -> Nil
    }
  })
}

pub fn change_routes(e: Event) -> Nil {
  let assert Ok(name) =
    e
    |> event.target()
    |> dynamic.unsafe_coerce()
    |> element.get_attribute("name")
  case name {
    "startAfter" -> change_start_time(e)
    "direction" -> change_direction(e)
    _ -> change_selected_routes(e)
  }
}

const levis_lat = 46.736269

const levis_lon = -71.2535253

const initial_zoom = 11.65

pub fn init() -> Nil {
  globals.init()

  let map =
    leaflet_map.new("map")
    |> leaflet_map.set_view(lat_lng.new(levis_lat, levis_lon), initial_zoom)

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
    |> result.try(fn(input) {
      let assert Ok(value) =
        input |> element.get_attribute("value") |> result.map(int.parse)
      value
    })
    |> result.map(globals.set_direction)

  list_route_checkboxes()
  |> array.to_list()
  |> list.filter(element.get_checked)
  |> list.each(fn(checkbox) {
    let assert Ok(name) = element.get_attribute(checkbox, "name")
    add_line(name)
  })

  let assert Ok(start_time_preview) =
    document.get_element_by_id("startTimePreview")

  globals.set_start_time_preview(start_time_preview)

  let assert Ok(start_time) =
    document.query_selector("input[name=startAfter]")
    |> result.then(element.value)
    |> result.then(int.parse)

  globals.set_start_time(start_time)

  element.set_text_content(
    start_time_preview,
    frontend.format_start_time(start_time),
  )

  Nil
}
