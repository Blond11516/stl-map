import common/route_json.{type RouteJson}
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/string

pub type Time {
  Time(hour: Int, minute: Int, second: Int)
}

pub fn compare_times(a: Time, b: Time) -> Int {
  let total_a_seconds = a.hour + a.minute + a.second
  let total_b_seconds = b.hour + b.minute + b.second

  total_a_seconds - total_b_seconds
}

pub fn time_from_minutes(total_minutes: Int) -> Time {
  let hours = total_minutes / 60
  let assert Ok(minutes) = int.modulo(total_minutes, 60)

  Time(hours, minutes, 0)
}

pub fn parse_time(raw: String) -> Time {
  let assert [hour, minute, second] = string.split(raw, ":")

  let assert Ok(hour) = int.parse(hour)
  let assert Ok(minute) = int.parse(minute)
  let assert Ok(second) = int.parse(second)

  Time(hour, minute, second)
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
