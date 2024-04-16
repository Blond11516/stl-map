addEventListener("load", () => {
  const levisLat = 46.736269;
  const levisLon = -71.2535253;
  const map = L.map("map").setView([levisLat, levisLon], 11.65);

  // TODO implement OSM usage policies: https://operations.osmfoundation.org/policies/tiles/
  L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution:
      '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  }).addTo(map);

  fetch("routes.json").then((res) =>
    res.json().then((routes) => L.polyline([routes[0].points]).addTo(map))
  );
});
