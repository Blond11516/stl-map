export function fetch_route(route_id) {
  return fetch(`./${route_id.toLowerCase()}.json`).then((res) => res.json());
}
