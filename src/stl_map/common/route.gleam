import stl_map/common/direction.{type Direction}
import stl_map/common/time_of_day.{type TimeOfDay}

pub type Route {
  Route(id: String, name: String, trips: List(Trip), color: String)
}

pub type Trip {
  Trip(
    id: String,
    headsign: String,
    shape: Shape,
    stops: List(Stop),
    start_time: TimeOfDay,
    direction: Direction,
  )
}

pub type Shape {
  Shape(id: String, points: List(ShapePoint))
}

pub type ShapePoint {
  ShapePoint(lat: Float, lon: Float)
}

pub type Stop {
  Stop(id: String, arrival_time: TimeOfDay, departure_time: TimeOfDay)
}
