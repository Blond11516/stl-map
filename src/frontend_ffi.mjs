import { to_list } from "../gleam_javascript/gleam/javascript/array.mjs";
import * as time_of_day from "./stl_map/time_of_day.mjs";
import { Ok, Error } from "../prelude.mjs";

export function fetch_route(route_id) {
  return fetch(`./routes/${route_id.toUpperCase()}.json`)
    .then((res) => res.json())
    .then((res) => {
      return {
        name: res.name,
        trips: to_list(
          res.trips.map((trip) => ({
            points: to_list(trip.points.map((point) => to_list(point))),
            stops: to_list(
              trip.stops.map((stop) => ({
                ...stop,
                point: to_list(stop.point),
              }))
            ),
            start_time: time_of_day.parse(trip.start_time),
            direction: trip.direction,
          }))
        ),
        color: res.color,
      };
    });
}

export function assert_is_element(dyn) {
  if (dyn instanceof Element) {
    return new Ok(dyn);
  } else {
    return new Error(null);
  }
}
