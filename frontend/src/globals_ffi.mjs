import globals from "./globals.mjs";

export function get_start_time_preview() {
  return globals.startTimePreview;
}

export function set_start_time(value) {
  globals.startTime = value;
}

export function get_polylines() {
  return globals.polylines;
}
