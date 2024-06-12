import {
  compare_times,
  time_from_minutes,
  parse_time,
  get_route_data,
  format_start_time,
} from "./frontend.mjs";
import globals from "./globals.mjs";
import * as line from "./line.mjs";
import * as _document from "../plinth/plinth/browser/document.mjs";
import * as element from "../plinth/plinth/browser/element.mjs";
import * as map from "./frontend/leaflet/map.mjs";
import * as latLng from "./frontend/leaflet/lat_lng.mjs";
import * as tileLayer from "./frontend/leaflet/tile_layer.mjs";
import * as index from "./index2.mjs";

const formId = "routes-form";

addEventListener("load", () => {
  const levisLat = 46.736269;
  const levisLon = -71.2535253;

  globals.map = map.new$("map");
  globals.map = map.set_view(
    globals.map,
    latLng.new$(levisLat, levisLon),
    11.65
  );

  // TODO implement OSM usage policies: https://operations.osmfoundation.org/policies/tiles/
  const osmTileLayer = tileLayer.new$(
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    {
      maxZoom: 19,
      attribution:
        '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }
  );
  tileLayer.add_to(osmTileLayer, globals.map);

  const form = _document.get_element_by_id(formId)[0];

  element.add_event_listener(form, "change", changeRoutes);

  globals.direction = parseInt(
    _document.query_selector("input[name=direction]:checked")[0].value
  );

  for (const checkbox of index.list_route_checkboxes()) {
    if (checkbox.checked) {
      addLine(checkbox.name);
    }
  }

  globals.startTimePreview = _document.get_element_by_id("startTimePreview")[0];
  globals.startTime = _document.query_selector(
    "input[name=startAfter]"
  )[0].value;
  globals.startTimePreview.textContent = format_start_time(globals.startTime);
});

/**
 * @param {Event} e
 * @listens Event
 */
function changeRoutes(e) {
  switch (e.target.name) {
    case "startAfter":
      changeStartTime(e);
      break;
    case "direction":
      changeDirection(e);
      break;
    default:
      changeSelectedRoutes(e);
      break;
  }
}

/**
 * @param {Event} e
 */
function changeStartTime(e) {
  globals.startTimePreview.textContent = format_start_time(e.target.value);
  globals.startTime = Number.parseInt(e.target.value);

  for (const checkbox of index.list_route_checkboxes()) {
    if (checkbox.checked) {
      const routeName = checkbox.name;
      index.remove_line(routeName);
      addLine(routeName);
    }
  }
}

/**
 * @param {Event} e
 */
function changeDirection(e) {
  globals.direction = parseInt(e.target.value);

  for (const checkbox of index.list_route_checkboxes()) {
    if (checkbox.checked) {
      const routeName = checkbox.name;
      index.remove_line(routeName);
      addLine(routeName);
    }
  }
}

/**
 * @param {Event} e
 */
function changeSelectedRoutes(e) {
  if (e.target.checked) {
    addLine(e.target.name);
  } else {
    index.remove_line(e.target.name);
  }
}

/**
 * @param {string} routeId
 */
async function addLine(routeId) {
  const route = await get_route_data(routeId);
  const startTimeObject = time_from_minutes(globals.startTime);
  const trip = route.trips
    .toSorted((a, b) => {
      const aTime = parse_time(a.start_time);
      const bTime = parse_time(b.start_time);
      return compare_times(aTime, bTime);
    })
    .find((trip) => {
      if (trip.direction !== globals.direction) {
        return false;
      }

      const tripStartTime = parse_time(trip.start_time);

      return compare_times(startTimeObject, tripStartTime) < 0;
    });

  if (trip) {
    line.add_to_map(routeId, { points: trip.points, color: route.color });
  }
}

/**
 * @typedef {Object} Time
 * @property {number} hour
 * @property {number} minute
 * @property {number} second
 */

/**
 * @typedef {Object} Point
 * @property {number} lat
 * @property {number} lon
 */

/**
 * @typedef {Object} Trip
 * @property {string} start_time
 * @property {Array<Point>} points
 * @property {number} direction
 */

/**
 * @typedef {Object} Route
 * @property {string} color
 * @property {Array<Trip>} trips
 */
