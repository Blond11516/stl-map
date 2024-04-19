import gleam/int
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
