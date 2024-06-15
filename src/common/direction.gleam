pub type Direction {
  Zero
  One
}

pub fn from_int(direction_id: Int) -> Direction {
  case direction_id {
    0 -> Zero
    1 -> One
    _ -> panic as "Direction IDs should always be 0 or 1"
  }
}

pub fn to_int(direction: Direction) -> Int {
  case direction {
    Zero -> 0
    One -> 1
  }
}
