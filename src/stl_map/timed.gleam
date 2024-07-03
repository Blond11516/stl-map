import birl
import birl/duration
import gleam/int
import gleam/io

pub fn timed(operation_name: String, operation: fn() -> a) -> a {
  io.println(operation_name <> ": Operation started")

  let before_time = birl.now()
  let operation_result = operation()
  let after_time = birl.now()

  let milliseconds =
    birl.difference(after_time, before_time)
    |> duration.blur_to(duration.MilliSecond)

  io.println(
    operation_name
    <> ": Operation completed in "
    <> int.to_string(milliseconds)
    <> "ms.",
  )

  operation_result
}
