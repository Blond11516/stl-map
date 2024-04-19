let map;
let polylines = {};

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

  for (const label of form.children) {
    const checkbox = label.children[0];
    if (checkbox.checked) {
      addLine(checkbox.name);
    }
  }
});

/**
 * @param {Event} e
 * @listens Event
 */
function changeRoutes(e) {
  if (e.target.checked) {
    addLine(e.target.name);
  } else {
    polylines[e.target.name].remove();
    delete polylines[e.target.name];
  }
  console.log(e);
}

/**
 * @param {string} routeId
 */
function addLine(routeId) {
  fetch(`./${routeId.toLowerCase()}.json`).then((res) =>
    res.json().then((routes) => {
      const line = L.polyline([routes[0].trips[0].points], {
        color: routes[0].color,
      });
      line.addTo(map);
      polylines[routeId] = line;
    })
  );
}
