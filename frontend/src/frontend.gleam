import common/route_json.{type RouteJson}
import common/time_of_day.{type TimeOfDay, TimeOfDay}
import gleam/int
import gleam/javascript/promise.{type Promise}

pub fn time_from_minutes(total_minutes: Int) -> TimeOfDay {
  let hours = total_minutes / 60
  let assert Ok(minutes) = int.modulo(total_minutes, 60)

  TimeOfDay(hours, minutes, 0)
}

pub fn get_route_data(route_id: String) -> Promise(RouteJson) {
  fetch_route(route_id)
}

pub fn format_start_time(total_minutes: Int) -> String {
  let time = time_from_minutes(total_minutes)

  int.to_string(time.hour) <> ":" <> int.to_string(time.minute)
}

@external(javascript, "./frontend_ffi.mjs", "fetch_route")
fn fetch_route(route_id: String) -> Promise(RouteJson)
