export function get_element_by_id(id) {
  return document.getElementById(id);
}

export function query_selector(selector) {
  return document.querySelector(selector);
}

export function query_selector_all(selector) {
  return document.querySelectorAll(selector);
}
