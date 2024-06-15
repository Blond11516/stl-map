import globals from "./globals.mjs";

export function get_start_time_preview() {
  return globals.startTimePreview;
}

export function set_start_time_preview(preview) {
  globals.startTimePreview = preview;
}

export function get_start_time() {
  return globals.startTime;
}

export function set_start_time(value) {
  globals.startTime = value;
}

export function get_polylines() {
  return globals.polylines;
}

export function get_direction() {
  return globals.direction;
}

export function set_direction(direction) {
  globals.direction = direction;
}

export function set_map(map) {
  globals.map = map;
}