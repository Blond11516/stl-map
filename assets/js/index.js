let map;
let polylines = {};

/**
 * @type {Element}
 */
let startTimePreview;

let startTime;

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

  const form = document.getElementById("routes-form");

  form.addEventListener("change", changeRoutes);

  const routeCheckboxes = document.querySelectorAll(
    `#${form.id} input[type=checkbox]`
  );
  for (const checkbox of routeCheckboxes) {
    if (checkbox.checked) {
      addLine(checkbox.name);
    }
  }

  startTimePreview = document.getElementById("startTimePreview");
  startTime = document.querySelector("input[name=startAfter]").value;
  startTimePreview.textContent = formatStartTime(startTime);
});

/**
 * @param {Event} e
 * @listens Event
 */
function changeRoutes(e) {
  if (e.target.name === "startAfter") {
    changeStartTime(e);
  } else {
    changeSelectedRoutes(e);
  }
}

/**
 * @param {Event} e
 */
function changeStartTime(e) {
  startTimePreview.textContent = formatStartTime(e.target.value);
  startTime = Number.parseInt(e.target.value);

  for (const routeName of Object.keys(polylines)) {
    removeLine(routeName);
    addLine(routeName);
  }
}

/**
 * @param {Number} totalMinutes
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

function removeLine(routeId) {
  polylines[routeId].remove();
  delete polylines[routeId];
}

/**
 * @param {string} routeId
 */
function addLine(routeId) {
  fetch(`./${routeId.toLowerCase()}.json`).then((res) =>
    res.json().then((route) => {
      const startTimeObject = timeFromMinutes(startTime);
      const trip = route.trips
        .toSorted((a, b) => {
          const aTime = parseTime(a.start_time);
          const bTime = parseTime(b.start_time);
          return compareTimes(aTime, bTime);
        })
        .find((trip) => {
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
    })
  );
}

/**
 * @param {string} raw
 */
function parseTime(raw) {
  const [hour, minute, second] = raw.split(":");
  return {
    hour: Number.parseInt(hour),
    minute: Number.parseInt(minute),
    second: Number.parseInt(second),
  };
}

function timeFromMinutes(totalMinutes) {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  return {
    hour: hours,
    minute: minutes,
    second: 0,
  };
}

function compareTimes(a, b) {
  const totalASeconds = a.hour * 3600 + a.minute * 60 + a.second;
  const totalBSeconds = b.hour * 3600 + b.minute * 60 + b.second;

  return totalASeconds - totalBSeconds;
}
