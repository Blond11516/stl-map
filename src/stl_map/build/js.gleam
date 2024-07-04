import esgleam

pub fn main() -> Nil {
  build()
}

pub fn build() -> Nil {
  let _ =
    esgleam.new("./dist/js")
    |> esgleam.entry("stl_map/frontend/index2.gleam")
    |> esgleam.minify(True)
    |> esgleam.platform(esgleam.Browser)
    |> esgleam.target("es2022")
    |> esgleam.raw("--sourcemap")
    |> esgleam.bundle()

  Nil
}
