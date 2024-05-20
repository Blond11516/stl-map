let map;
/**
 * @type {Object<string, any>}
 */
let polylines = {};
/**
 * @type {Object<string, Route>}
 */
let routes = {};

/**
 * @type {Element}
 */
let startTimePreview;

/**
 * @type {number}
 */
let startTime;

/**
 * @type {number}
 */
let direction;

const formId = "routes-form";

addEventListener("load", () => {
  const levisLat = 46.736269;
  const levisLon = -71.2535253;
  map = L.map("map").setView([levisLat, levisLon], 11.65);

  // TODO implement OSM usage policies: https://operations.osmfoundation.org/policies/tiles/
  L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution:
      '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  }).addTo(map);

  const form = document.getElementById(formId);

  form.addEventListener("change", changeRoutes);

  direction = parseInt(
    document.querySelector("input[name=direction]:checked").value
  );

  for (const checkbox of listRouteCheckboxes()) {
    if (checkbox.checked) {
      addLine(checkbox.name);
    }
  }

  startTimePreview = document.getElementById("startTimePreview");
  startTime = document.querySelector("input[name=startAfter]").value;
  startTimePreview.textContent = formatStartTime(startTime);
});

/**
 * @returns {Array<Element>}
 */
function listRouteCheckboxes() {
  const checkboxes = Array.from(
    document.querySelectorAll(`#${formId} input[type=checkbox]`)
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
  startTimePreview.textContent = formatStartTime(e.target.value);
  startTime = Number.parseInt(e.target.value);

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
  direction = parseInt(e.target.value);

  for (const checkbox of listRouteCheckboxes()) {
    if (checkbox.checked) {
      const routeName = checkbox.name;
      removeLine(routeName);
      addLine(routeName);
    }
  }
}

/**
 * @param {Number} totalMinutes
 * @returns {string}
 */
function formatStartTime(totalMinutes) {
  const { hour, minute } = timeFromMinutes(totalMinutes);

  return `${hour}:${minute}`;
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
  if (routeId in polylines) {
    polylines[routeId].remove();
    delete polylines[routeId];
  }
}

/**
 * @param {string} routeId
 */
async function addLine(routeId) {
  const route = await getRouteData(routeId);
  const startTimeObject = timeFromMinutes(startTime);
  const trip = route.trips
    .toSorted((a, b) => {
      const aTime = parseTime(a.start_time);
      const bTime = parseTime(b.start_time);
      return compareTimes(aTime, bTime);
    })
    .find((trip) => {
      if (trip.direction !== direction) {
        return false;
      }

      const tripStartTime = parseTime(trip.start_time);

      return compareTimes(startTimeObject, tripStartTime) < 0;
    });

  if (trip) {
    const line = L.polyline([trip.points], {
      color: route.color,
    });
    line.addTo(map);
    polylines[routeId] = line;
  }
}

/**
 * @param {string} routeId
 * @returns {Promise<Route>}
 */
async function getRouteData(routeId) {
  if (routeId in routes) {
    return routes[routeId];
  }

  const res = await fetch(`./${routeId.toLowerCase()}.json`);
  const route = await res.json();
  routes[routeId] = route;
  return route;
}

/**
 * @param {string} raw
 * @returns {Time}
 */
function parseTime(raw) {
  const [hour, minute, second] = raw.split(":");
  return {
    hour: Number.parseInt(hour),
    minute: Number.parseInt(minute),
    second: Number.parseInt(second),
  };
}

/**
 * @param {number} totalMinutes
 * @returns {Time}
 */
function timeFromMinutes(totalMinutes) {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  return {
    hour: hours,
    minute: minutes,
    second: 0,
  };
}

/**
 * @param {Time} a
 * @param {Time} b
 * @returns {number}
 */
function compareTimes(a, b) {
  const totalASeconds = a.hour * 3600 + a.minute * 60 + a.second;
  const totalBSeconds = b.hour * 3600 + b.minute * 60 + b.second;

  return totalASeconds - totalBSeconds;
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
