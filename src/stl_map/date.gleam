import gleam/int
import gleam/list
import gleam/string

pub type Date {
  Date(year: Int, month: Int, day: Int)
}

pub fn parse(raw: String) -> Date {
  let date_graphemes = string.to_graphemes(raw)
  let assert Ok(year) =
    date_graphemes |> list.take(4) |> string.join("") |> int.parse()
  let assert Ok(month) =
    date_graphemes
    |> list.drop(4)
    |> list.take(2)
    |> string.join("")
    |> int.parse()
  let assert Ok(day) =
    date_graphemes
    |> list.drop(6)
    |> list.take(2)
    |> string.join("")
    |> int.parse()

  Date(year:, month:, day:)
}

pub fn present(date: Date) -> String {
  [int.to_string(date.day), int.to_string(date.month), int.to_string(date.year)]
  |> string.join("-")
}
