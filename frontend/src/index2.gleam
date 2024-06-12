import frontend/globals
import gleam/javascript/array.{type Array}
import gleam/option.{Some}
import line
import plinth/browser/document
import plinth/browser/element_type.{type Element}
import plinth/browser/object

const form_id = "routes-form"

pub fn list_route_checkboxes() -> Array(Element) {
  document.query_selector_all("#" <> form_id <> " input[type=checkbox]")
}

// pub fn change_start_time(e: Event) -> Nil {
//   let assert Ok(start_time) = int.parse(e.target.value)

//   element.set_attribute(
//     globals.get_start_time_preview(),
//     "textContent",
//     frontend.format_start_time(start_time),
//   )
//   globals.set_start_time(start_time)

//   list_route_checkboxes()
//   |> array.to_list()
//   |> list.each(fn (checkbox) {
//     case checkbox.checked {
//       True -> {
//         let route_name = checkbox.name
//         remove_line(route_name)
//         add_line(route_name)
//       }
//       False -> Nil
//     }
//   })
// }

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
