import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/javascript/promise.{type Promise}
import plinth/browser/element.{type Element}
import stl_map/route_json.{type RouteJson}
import stl_map/time_of_day.{type TimeOfDay, TimeOfDay}

pub fn time_from_minutes(total_minutes: Int) -> TimeOfDay {
  let hour = total_minutes / 60
  let assert Ok(minute) = int.modulo(total_minutes, 60)

  TimeOfDay(hour:, minute:, second: 0)
}

pub fn get_route_data(route_id: String) -> Promise(RouteJson) {
  fetch_route(route_id)
}

pub fn format_start_time(total_minutes: Int) -> String {
  let time = time_from_minutes(total_minutes)

  int.to_string(time.hour) <> ":" <> int.to_string(time.minute)
}

@external(javascript, "../../frontend_ffi.mjs", "fetch_route")
fn fetch_route(route_id: String) -> Promise(RouteJson)

@external(javascript, "../../frontend_ffi.mjs", "assert_is_element")
pub fn assert_is_element(dyn: Dynamic) -> Result(Element, Nil)
