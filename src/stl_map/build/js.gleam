import esgleam

pub fn main() -> Nil {
  build()
}

pub fn build() -> Nil {
  let bundle_result =
    esgleam.new("./dist/js")
    |> esgleam.entry("stl_map/frontend/index2.gleam")
    |> esgleam.minify(True)
    |> esgleam.platform(esgleam.Browser)
    |> esgleam.target("es2023")
    |> esgleam.raw("--sourcemap")
    |> esgleam.bundle()

  case bundle_result {
    Ok(_) -> Nil
    Error(message) -> panic as message
  }
}
