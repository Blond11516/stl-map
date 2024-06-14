import common/route.{ShapePoint}
import common/time_of_day
import frontend
import frontend/globals
import gleam/int
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/option.{Some}
import gleam/order.{Lt}
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

  element.set_attribute(
    globals.get_start_time_preview(),
    "textContent",
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
