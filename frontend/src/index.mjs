import {
  compare_times,
  time_from_minutes,
  parse_time,
  get_route_data,
  format_start_time,
} from "./frontend.mjs";
import globals from "./globals.mjs";
// import * as _document from "./document.mjs";
// import * as element from "./element.mjs";
import * as _document from "../plinth/plinth/browser/document.mjs";
import * as element from "../plinth/plinth/browser/element.mjs";

const formId = "routes-form";

addEventListener("load", () => {
  const levisLat = 46.736269;
  const levisLon = -71.2535253;
  globals.map = L.map("map").setView([levisLat, levisLon], 11.65);

  // TODO implement OSM usage policies: https://operations.osmfoundation.org/policies/tiles/
  L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution:
      '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  }).addTo(globals.map);

  const form = _document.get_element_by_id(formId)[0];

  element.add_event_listener(form, "change", changeRoutes);

  globals.direction = parseInt(
    _document.query_selector("input[name=direction]:checked")[0].value
  );

  for (const checkbox of listRouteCheckboxes()) {
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
 * @returns {Array<Element>}
 */
function listRouteCheckboxes() {
  const checkboxes = Array.from(
    _document.query_selector_all(`#${formId} input[type=checkbox]`)
  );
  return checkboxes;
}

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

  for (const checkbox of listRouteCheckboxes()) {
    if (checkbox.checked) {
      const routeName = checkbox.name;
      removeLine(routeName);
      addLine(routeName);
    }
  }
}

/**
 * @param {Event} e
 */
function changeDirection(e) {
  globals.direction = parseInt(e.target.value);

  for (const checkbox of listRouteCheckboxes()) {
    if (checkbox.checked) {
      const routeName = checkbox.name;
      removeLine(routeName);
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
    removeLine(e.target.name);
  }
}

/**
 * @param {string} routeId
 */
function removeLine(routeId) {
  if (routeId in globals.polylines) {
    globals.polylines[routeId].remove();
    delete globals.polylines[routeId];
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
    const line = L.polyline([trip.points], {
      color: route.color,
    });
    line.addTo(globals.map);
    globals.polylines[routeId] = line;
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
