import event.{type Event}

pub type Element

@external(javascript, "./element_ffi.mjs", "add_event_listener")
pub fn add_event_listener(
  element: Element,
  event: String,
  callback: fn(Event) -> Nil,
) -> Nil
