import { to_list } from "../gleam_javascript/gleam/javascript/array.mjs";
import { parse_time_of_day } from "./common/time_of_day.mjs";

export function fetch_route(route_id) {
  return fetch(`./${route_id.toLowerCase()}.json`)
    .then((res) => res.json())
    .then((res) => {
      return {
        name: res.name,
        trips: to_list(
          res.trips.map((trip) => ({
            points: to_list(trip.points.map((point) => to_list(point))),
            stops: to_list(trip.stops),
            start_time: parse_time_of_day(trip.start_time),
            direction: trip.direction,
          }))
        ),
        color: res.color,
      };
    });
}
