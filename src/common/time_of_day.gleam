import gleam/int
import gleam/order.{type Order}
import gleam/string

pub type TimeOfDay {
  TimeOfDay(hour: Int, minute: Int, second: Int)
}

pub fn parse_time_of_day(raw: String) -> TimeOfDay {
  let assert [raw_hour, raw_minute, raw_second] = string.split(raw, ":")
  let assert Ok(hour) = int.parse(raw_hour)
  let assert Ok(minute) = int.parse(raw_minute)
  let assert Ok(second) = int.parse(raw_second)

  TimeOfDay(hour, minute, second)
}

pub fn present(time_of_day: TimeOfDay) -> String {
  [
    int.to_string(time_of_day.hour),
    int.to_string(time_of_day.minute),
    int.to_string(time_of_day.second),
  ]
  |> string.join(":")
}

pub fn compare(a: TimeOfDay, b: TimeOfDay) -> Order {
  let total_a_seconds = a.hour * 3600 + a.minute * 60 + a.second
  let total_b_seconds = b.hour * 3600 + b.minute * 60 + b.second

  int.compare(total_a_seconds, total_b_seconds)
}

pub fn as_minutes(time_of_day: TimeOfDay) -> Int {
  time_of_day.hour * 60 + time_of_day.minute
}
