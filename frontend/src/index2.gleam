import gleam/javascript/array.{type Array}
import plinth/browser/document
import plinth/browser/element_type.{type Element}

const form_id = "routes-form"

pub fn list_route_checkboxes() -> Array(Element) {
  document.query_selector_all("#" <> form_id <> " input[type=checkbox]")
}
