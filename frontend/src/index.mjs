import { format_start_time } from "./frontend.mjs";
import globals from "./globals.mjs";
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

  element.add_event_listener(form, "change", index.change_routes);

  globals.direction = parseInt(
    _document.query_selector("input[name=direction]:checked")[0].value
  );

  for (const checkbox of index.list_route_checkboxes()) {
    if (checkbox.checked) {
      index.add_line(checkbox.name);
    }
  }

  globals.startTimePreview = _document.get_element_by_id("startTimePreview")[0];
  globals.startTime = _document.query_selector(
    "input[name=startAfter]"
  )[0].value;
  globals.startTimePreview.textContent = format_start_time(globals.startTime);
});

// /**
//  * @param {Event} e
//  * @listens Event
//  */
// function changeRoutes(e) {
//   switch (e.target.name) {
//     case "startAfter":
//       index.change_start_time(e);
//       break;
//     case "direction":
//       index.change_direction(e);
//       break;
//     default:
//       index.change_selected_routes(e);
//       break;
//   }
// }

// /**
//  * @param {Event} e
//  */
// function changeDirection(e) {
//   globals.direction = parseInt(e.target.value);

//   for (const checkbox of index.list_route_checkboxes()) {
//     if (checkbox.checked) {
//       const routeName = checkbox.name;
//       index.remove_line(routeName);
//       index.add_line(routeName);
//     }
//   }
// }

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
